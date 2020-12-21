# fishnet
Data workflows to support curation and distribution of fisheries data for ML applications at https://www.fishnet.ai

Abstractly the work flow consists of receiving HDDs from EM vendors with raw video and sensor data as well as 'declarations' or 'events' files that consist of events (fish catch) within each video. The task is then to extract a window of frames around each event and produce still images with labels (at the image level). Those data are then passed on to Samasource for addition of bounding boxes around the object of interst - which right not consists of fish on the deck (catch events). 

The python scripts (for each vendor) complete this task.

The outputs from each vendor template are imported and annotation data are managed in PostgreSQL.
