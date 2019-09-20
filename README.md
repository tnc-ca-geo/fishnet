# fishnet
Data pipelines to support curation and distribution of fisheries data for AI applications at https://www.fishnet.ai

Pipelines are segmented by EM Vendors. Currently we have data from AMR and Satlink. The pipeline is rudimentary right now and relies on a combination of python and sql. At the highest level the work flow consists of receiving HDDs from EM vendors with raw video and sensor data as well as 'declarations' files that consist of events (fish catch) within each video. The task is to extract a window of frames around each event and produce still images with labels (at the image level). Those data are then passed on to Samasource for addition of bounding boxes around the object of interst - which right not consists of fish on the deck (catch events).

##AMR

1. HDDs with trip folders - e.g. AUCF03-12326-190506_215742
2. Import video metadata file into postgresql (public.amr_file_video_metadata) - e.g. /AUCF03-12326-190506_215742/SensorData/AUCF03-12326-190506_215742IH.txt
3. 
