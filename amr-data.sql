
-- #########################################################
-- ## IMPORT AND MUNGE AFMA DECLARATION DATA AND METADATA ##
-- #########################################################
/*
select filename
from ofvd_labels_v010
group by filename
*/

/*
drop table if exists labels_lookup;
create table labels_lookup
    (
    id serial not null,
    raw_label varchar,
    code varchar,
    label_l1 varchar,
    lable_l2 varchar,
    constraint labels_lookup_pkey primary key (id)
    );
    
insert into labels_lookup (raw_label, label_l1)
select raw_label, label_l1
from fishname_lookup

*/

/*
insert into labels_lookup (raw_label)
select label_l1 
from ofvd_labels_v010
group by label_l1
*/




--update afma_catch
--set dt_vid_link = to_char(ctch_dt_tm,'YYMMDD_HH24MISS')



/*
drop table if exists afma_catch;
set datestyle to DMY;
create table afma_catch
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
    constraint afma_catch_pkey primary key (c_id)
    );

copy afma_catch
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

--update afma_video_file_metadata
--set vidstart_dt_tm = to_timestamp (left(split_part((split_part(fname, '-',6)),'(',1), 13),'YYMMDD_HH24MISS')
--where count = 0

--update afma_video_file_metadata
--set length_char = length_hrs::varchar || ' hours'
--where count = 0

--update afma_video_file_metadata
--set vidend_dt_tm = vidstart_dt_tm + length_char::interval
--where count = 0






/*
drop table if exists afma_video_file_metadata;

create table afma_video_file_metadata
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

copy afma_video_file_metadata
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




