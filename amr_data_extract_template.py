import pandas as pd
import json
import numpy as np
import os
import glob
import subprocess
import datetime
import pytz
from tqdm import tqdm

# Directory for saving outputs
TOP_DIR = ""
# Location of Video data
VIDEO_DRIVE = ""
EVT_DURATION = '00:00:30'
#EVT_DURATION/2 typically, but flexible
EVT_OFFSET = '00:00:15'
#Images/second to save off. Ensure that this is not greater than video fps
FRAME_RATE = '1'

def get_video_duration(filename):
    """Calcualates the duration of a video in seconds
    """
    result = subprocess.run(["ffprobe", "-v", "error", "-show_entries",
                             "format=duration", "-of",
                             "default=noprint_wrappers=1:nokey=1", filename],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT)
    try:
        duration = float(result.stdout)
    except:
        print("Error reading file")
        duration = 1.0
    return duration

def create_video_metadata():
    columns = ['fpath','fname','vidstart_ts','vidend_ts']
    df = pd.DataFrame(columns=columns)
    for root,_,files in os.walk(VIDEO_DRIVE):
        for f in files:
            if not f.endswith('.MP4'):
                continue

            vidstart_time = f.split('_')[-2]
            vidstart_date = '20' + f.split('-')[-1].split('_')[0]
            vidstart_ts = datetime.datetime.strptime(
                vidstart_date + ' ' + vidstart_time,
                '%Y%m%d %H%M%S')
            vidstart_ts = vidstart_ts.replace(tzinfo=pytz.UTC)
            vidend_ts = vidstart_ts + datetime.timedelta(seconds=get_video_duration(os.path.join(root,f)))
            vidend_ts = vidend_ts.replace(tzinfo=pytz.UTC)
            cur_row = pd.DataFrame([[
                os.path.join(root,f),
                f,
                vidstart_ts,
                vidend_ts,
                ]],columns=columns)
            df = df.append(cur_row)
    
    df.to_csv(TOP_DIR + 'video_metadata.csv',index=False)

    return df

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

def get_time_in_video(vid_event, catch_event):
    td = pd.to_datetime(evt['CTCH_DT_TM'],utc=True,dayfirst=True) - vid_event['vidstart_ts']
    td_string = '{:02}:{:02}:{:02}'.format(
                                        td.components.hours, td.components.minutes, td.components.seconds)
    return td_string

def get_event_images(event):
    out_folder = TOP_DIR
    out_base = os.path.basename(event[0]).split('.MP4')[0]
    out_id = str(event[2].ID)
    str_time = event[1]
    input_video = event[0]
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
        '2',
        out_folder + out_base + '_' + out_id + '_%03d.jpg' 
    ]
    
    subprocess.call(cmd)  

if __name__ == "__main__":
    event_data = pd.read_csv(os.path.join(TOP_DIR,'catch_events.csv'))
    try:
        vid_df = pd.read_csv(TOP_DIR + 'video_metadata.csv')
        vid_df['vidstart_ts'] = pd.to_datetime(vid_df['vidstart_ts'],utc=True)
        vid_df['vidend_ts'] = pd.to_datetime(vid_df['vidend_ts'],utc=True)
    except:
        vid_df = create_video_metadata()

    for idx,evt in tqdm(event_data.iterrows()):
        mask = (vid_df['vidstart_ts'] < pd.to_datetime(evt['CTCH_DT_TM'],utc=True,dayfirst=True)) & \
        (vid_df['vidend_ts'] > pd.to_datetime(evt['CTCH_DT_TM'],utc=True,dayfirst=True))
        results = vid_df.loc[mask]
        for vid in range(len(results)):
            event_time = get_time_in_video(results.iloc[vid], evt)
            get_event_images((results.iloc[vid]['fpath'], event_time, evt))











