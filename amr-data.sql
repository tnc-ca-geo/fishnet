
-- #########################################################
-- ## IMPORT AND MUNGE AMR DECLARATION DATA AND METADATA ##
-- #########################################################


/*
drop table if exists amr_events;
set datestyle to DMY;
create table amr_events
    (
    c_id serial not null,
    ID integer,
    EM_FSHG_HL_ID integer,
    OPN_NBR integer,
    EM_DTAID_ID integer,
    DTA_ID varchar,
    FSHG_TRIP_ID integer,
    CTCH_DT_TM timestamp,
    CTCH_LAT numeric (7,5),
    CTCH_LONGTD numeric (8,5),
    CAAB_CODE integer,
    STD_NAME varchar,
    SPC_NAME varchar,
    FATE varchar,
    LIFE_STATUS varchar,
    SEX varchar,
    NBR_ANMLS varchar,
    CMNT varchar,
    dt_vid_link,
    constraint amr_events_pkey primary key (c_id)
    );

copy amr_events
    (
    ID,
    EM_FSHG_HL_ID,
    OPN_NBR,
    EM_DTAID_ID,
    DTA_ID,
    FSHG_TRIP_ID,
    CTCH_DT_TM,
    CTCH_LAT,
    CTCH_LONGTD,
    CAAB_CODE,
    STD_NAME,
    SPC_NAME,
    FATE,
    LIFE_STATUS,
    SEX,
    NBR_ANMLS,
    CMNT
    )

from '/Users/mmerrifield/Projects/fishnet/data/afma/declarations/66967_Catch.csv' csv delimiter ',' header
*/


--#################################################################
--## Update video metadata table with start, length, and end times
--#################################################################

--update amr_video_file_metadata
--set vidstart_ts = to_timestamp (left(split_part((split_part(fname, '-',6)),'(',1), 13),'YYMMDD_HH24MISS')
--where count = 0

--update amr_video_file_metadata
--set length_char = length_hrs::varchar || ' hours'
--where count = 0

--update amr_video_file_metadata
--set vidend_dt_tm = vidstart_dt_tm + length_char::interval
--where count = 0



/*
drop table if exists amr_video_file_metadata;

create table amr_video_file_metadata
    (
        id serial not null,
    count integer,
    fname varchar,
    cam integer,
    startdate integer,
    starttime integer,
    startms integer,
    nframes integer,
    fps numeric (6,4),
    Length_hrs numeric (6,4),
    codec varchar,
    status varchar,
    dt_vid_link varchar,
    vid_dt_ts timestamp,
    constraint afma_video_file_metadata_pkey primary key (id)
    );

copy amr_video_file_metadata
    (
    count,
    fname,
    cam,
    startdate,
    starttime,
    startms,
    nframes,
    fps,
    Length_hrs,
    codec,
    status
    )
    
from '/Users/mmerrifield/Projects/fishnet/data/afma/012455-181005-sensor-data/AUCF03-012455-181005_064134IH.txt'csv header

*/




