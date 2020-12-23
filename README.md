# fishnet data
Data workflows to support curation and distribution of fisheries data for ML applications at https://www.fishnet.ai

The big picture workflow consists of receiving HDDs from EM vendors with raw video and sensor data as well as 'declarations' or 'events' files that consist of events (fish catch) within each video. The task is then to extract a window of frames around each event and produce still images with labels (at the image level) that can subsequently be annotated with bounding boxes. The python scripts (for each vendor) complete this task.

