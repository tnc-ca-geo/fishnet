# fishnet
Data pipelines to support curation and distribution of fisheries data for AI applications at https://www.fishnet.ai

Pipelines are segmented by EM Vendors. Currently we have data from AMR (Arcipelago Marine Resources) and Satlink. The pipeline is rudimentary right now and relies on a combination of python and sql. All the labels are managed in a postgresql database. At the highest level the work flow consists of receiving HDDs from EM vendors with raw video and sensor data as well as 'declarations' or 'events' files that consist of events (fish catch) within each video. The task is to extract a window of frames around each event and produce still images with labels (at the image level). Those data are then passed on to Samasource for addition of bounding boxes around the object of interst - which right not consists of fish on the deck (catch events). 

The workflows for each vendor are similiar and mostly vary in the format of the raw data. I've tried to harmonize the tables in the database

### AMR

1. HDDs with trip folders - e.g. AUCF03-12326-190506_215742.
2. Import video metadata file into db (public.amr_file_video_metadata) - e.g. /AUCF03-12326-190506_215742/SensorData/AUCF03-12326-190506_215742IH.txt
3. populate vidstart_ts, vidend_ts, length, and dta_id
4. Import 'declarations' data into db - public.amr_events. The source of these declaration files are typically private government databases. They are essentially the EM vendor deliverable to gov / agency clients.
5. Make a fuzzy join between amr_catch and amr_file_video_metadata that produces a table that identifies the video file that catch event resides in. This output - amr_vid_x_catch is used as input for [extract.py](https://github.com/tnc-ca-geo/extract)
6. [extract.py](https://github.com/tnc-ca-geo/extract) creates captures still images around and event - user can input number of frames around each event to capture. This can be tricky because the declarations files tend to not be very accurate - e.g. the timestamp captured can be off by 10-20 seconds. This results in a lot of frames without interesting things in them.
7. Samasource is then provided image files (S3). Those images have the label in their filename. Samasource adds bounding boxes and delivers their data as csv.
8. That deliverable is then flattened with transform_sama_deliv.py
9. Those data are are then imported into db (public.ofid_labels_vXXX)
10. ofid_labels_vXXX is the source for final label files posted to [fishnet.ai](https://www.fishnet.ai)


### Satlink

