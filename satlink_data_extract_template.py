"""
This script will create segments of images from videos, based on event files provided by Satlink. The script relies on a specific csv file, called OBS_CATCH_MASTER.csv, which contains information about all the events. There is one row for each event. The relevant column is CATCH_DATE. Using this information, images are extracted from videos around each event using ffmpeg.

IMPORTANT: OBS_CATCH_MASTER.csv contains catch info from many different vessels and trips. It is important to filter out this information for the trips you are interested in, as dates overlap, which can give you garbage event outputs if you're just filtering on the event date, and not date + trip. It is suggested to clean the OBS_CATCH_MASTER.csv file itself, rather than filtering in this script, unless you have clear mappings to trips and column names.
"""

import pandas as pd 
import pickle
import subprocess
import os
import datetime
import pytz

CATCH_FILE = r'OBS_CATCH_MASTER File Path'
#Hard drive serial number for current extraction
HDD_NAME = r'WD-WCC4E7UYUH3T'
#Metadata save location
METADATA_SAVE = r''
#Base location to save outputs
BASE_OUTPUT = r''
#Base location that hard drive is mounted
VIDEO_DRIVE = 'D:\\'
#Amount of time to extract around an event. Event will be centered.
EVT_DURATION = '00:00:20'
#EVT_DURATION/2 typically, but flexible
EVT_OFFSET = '00:00:10'
#Images/second to save off. Ensure that this is not greater than video fps
FRAME_RATE = '2'

def get_event_images(event):
    if len(event) > 0:
        evt_counts = [evt[0].split('/')[0] == HDD_NAME for evt in event]
    else:
        return

    if not any(evt_counts):
        return

    for i,evt in enumerate(event):
        if evt_counts[i]:
            out_folder = os.path.splitext(evt[0])[0]
            out_dir = os.path.join(BASE_OUTPUT,out_folder + '/')
            os.makedirs(out_dir,exist_ok=True)
            out_base = evt[2][2]
            str_time = evt[1]
            input_video = os.path.join(VIDEO_DRIVE, evt[0].split(HDD_NAME + '/')[-1])
            format = '%H:%M:%S'
            event_start = datetime.datetime.strptime(str_time,format) - datetime.datetime.strptime(EVT_OFFSET,format)

            if event_start < datetime.timedelta(seconds=0):
                event_start = datetime.timedelta(seconds=0)
            
            event_start_string = str(event_start)

            cmd = [
                'ffmpeg',
                '-ss',
                event_start_string,
                '-i',
                input_video, 
                '-t',
                EVT_DURATION,
                '-vf',
                f'fps={FRAME_RATE},crop=in_w:in_h-50:0:50',
                '-qscale:v',
                2,
                out_dir + out_base + '_%03d.jpg' 
            ]
            subprocess.call(cmd)

def get_time_in_video(vid_event, catch_event):
    td = catch_event['CATCH_DATE'] - vid_event['vidstart_ts']
    td_string = '{:02}:{:02}:{:02}'.format(
                                        td.components.hours, td.components.minutes, td.components.seconds)
    return td_string

def get_videos_for_event(event_idx, catch_df, vid_df):

    catch_event = catch_df.iloc[event_idx]
    mask = (vid_df['vidstart_ts'] < catch_event['CATCH_DATE']) & \
           (vid_df['vidend_ts'] > catch_event['CATCH_DATE'])

    results = vid_df.loc[mask]
    vids = []

    for vid in range(len(results)):
        event_time = get_time_in_video(results.iloc[vid], catch_event)
        vids.append((results.iloc[vid]['fpath'], event_time, catch_event))

    return vids

def create_video_metadata():
    columns = ['fpath','fname','vidstart_ts','vidend_ts']
    df = pd.DataFrame(columns=columns)
    for root,_,files in os.walk(VIDEO_DRIVE):
        for f in files:
            if not f.endswith('.mp4'):
                continue

            vidstart_time = f.split('-')[1]
            vidstart_date = f.split('Hi')[1].split('-')[0]
            vidstart_ts = datetime.datetime.strptime(
                vidstart_date + ' ' + vidstart_time,
                '%Y%m%d %H%M%S')
            vidstart_ts = vidstart_ts.replace(tzinfo=pytz.UTC)
            #This is a little fragile, assumes constant video length 10 minutes
            vidend_ts = vidstart_ts + datetime.timedelta(minutes=10)
            vidend_ts = vidend_ts.replace(tzinfo=pytz.UTC)
            cur_row = pd.DataFrame([[
                HDD_NAME + '/' + os.path.join(root,f).split('D:\\')[1],
                f,
                vidstart_ts,
                vidend_ts,
                ]],columns=columns)
            df = df.append(cur_row)
    
    df.to_csv(METADATA_SAVE + '_' + HDD_NAME + '_metadata.csv',index=False)

    return df
    
if __name__ == "__main__":

    if os.path.exists('event_results_' + HDD_NAME + '.pkl'):
        print('Loading events...')
        event_results = pickle.load(open('event_results_' + HDD_NAME + '.pkl','rb'))
        print('Events loaded!')

    else:
        print('Calculating events...')
        catch_df = pd.read_csv(CATCH_FILE)
        catch_df['CATCH_DATE'] = pd.to_datetime(catch_df['CATCH_DATE'], utc=True)

        vid_df = create_video_metadata()
        vid_df['vidstart_ts'] = pd.to_datetime(vid_df['vidstart_ts'], utc=True)
        vid_df['vidend_ts'] = pd.to_datetime(vid_df['vidend_ts'], utc=True)

        event_results = []
        for i in range(len(catch_df)):
            event_vids = get_videos_for_event(i, catch_df, vid_df)
            event_results.append(event_vids)

        pickle.dump(event_results,open('event_results_' + HDD_NAME + '.pkl','wb'))
        print('Events calculated!')

    for event in event_results:
        get_event_images(event)