# fishnet data pipelines
Data workflows to support curation and distribution of fisheries data for ML applications at https://www.fishnet.ai

The workflow consists of receiving HDDs from EM service providers with raw video and annotation files that consist of events (fish catch) within each video. The task is then to extract a window of frames around each event and produce still images with labels (at the image level) that can subsequently be annotated with bounding boxes. The workflow varies slightly by EM service provider, thus prefixs in each script.

