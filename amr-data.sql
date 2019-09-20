
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


--update amr_video_file_metadata
--set vidstart_ts = to_timestamp (left(split_part((split_part(fname, '-',6)),'(',1), 13),'YYMMDD_HH24MISS')
--where count = 0

--update amr_video_file_metadata
--set length_char = length_hrs::varchar || ' hours'
--where count = 0

--update amr_video_file_metadata
--set vidend_ts = vidstart_ts + length_char::interval
--where count = 0



--drop table if exists amr_vid_x_catch;
insert into amr_vid_x_catch(fname,cam_num,vidstart_ts,catch_ts,vidend_ts,label_l1,label_l2)

select 
	meta.fname || '.MP4' as fname, 
	meta.cam as cam_num,
	meta.vidstart_ts,
	events.ctch_dt_tm as catch_ts, 
	meta.vidend_ts,
	lu.label_l1 as label_l1,
	lu.label_l2 as label_l2
	


from amr_video_file_metadata meta

	-- this makes a fuzzy join by looking for all the catch events that fall between the video start and 10 seconds before the end time
	left join amr_events events on events.ctch_dt_tm between meta.vidstart_ts and meta.vidend_ts - interval '10 sec'
	left join labels_lookup lu on lu.raw_label = events.std_name
	
where label_l1 is not null 
	and meta.dta_id = 'AUCF03-012029-181111_202044'
	--and meta.dta_id = 'AUCF03-012455-181005_064134'
order by ctch_dt_tm asc;







