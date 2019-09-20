--------------------------------------------------
-- IMPORT AND MUNGE SATLINK-DOS DECLARATION DATA
--------------------------------------------------

/*
create table satlink_obs_catch_work
    (
        id serial not null,
        obstrip_id varchar,
        l_set_id varchar,
        l_catch_id varchar,
        catch_date varchar,
        hook_no integer,
        sp_code varchar,
        fate_code varchar,
        cond_code varchar,
        cond_rel_code varchar,
        len_code varchar,
        sex_code varchar,
        lat varchar,
        lon varchar,
        comments_ varchar,
    constraint obs_catch_pkey primary key (id)
    )


copy satlink_obs_catch_work
    (
        obstrip_id,
        l_set_id,
        l_catch_id,
        catch_date,
        hook_no,
        sp_code,
        fate_code,
        cond_code,
        cond_rel_code,
        len_code,
        sex_code,
        lat,
        lon,
        comments_
    )

from '/Users/mmerrifield/Projects/fishnet/data/Palau/Palau-HDDs-XML-04182019/OBS_CATCH_MASTER2.csv' delimiter ',' csv header

-- OBS_CATCH_MASTER2.csv is created from parse-satlink.py in the same directory - it parses and stuffs all the raw 
-- XML data into a master csv file


*/


/*

---------------------------------------------------------------------
-- Create and populate metadata tables for HDDs and video filenames
---------------------------------------------------------------------

create table satlink_hdd_metadata
    ( 
    id serial not null,
    hdd_serial_num varchar,
    trip_id varchar,
    days integer,
    constraint satlink_hdd_metadata_pkey primary key (id)
    )

copy satlink_hdd_metadata
    (
    hdd_serial_num,
    trip_id,
    days
    )
from '/Users/mmerrifield/Projects/fishnet/data/Palau/hdd_x_trip_lookup.csv' csv header
*/


/*
create table satlink_video_file_metadata
    (
    id serial not null,
    fpath varchar,
	vidstart_ts timestamp,
	vidend_ts timestamp,
    constraint satlink_video_file_metadata_pkey primary key (id)
    )    

copy satlink_video_file_metadata (fpath)
from '/Users/mmerrifield/Projects/fishnet/data/Palau/WD-WCC4E7KS5S1N_file_list.txt'

select to_timestamp(substring(split_part(fpath, '/',4),6,15)),'YYYYMMDD-HH24MISS'
update satlink_video_file_metadata

--the last set of digits in the filename is the Unix EPOCH, convert that to a timestamp
update satlink_video_file_metadata
set vidstart_ts = to_timestamp(substring(fpath,55,10)::numeric) + interval '7 hours'

-- update vidstart to account for daylight savings times (in where statements)
update satlink_video_file_metadata
set vidstart_ts = to_timestamp(substring(fpath,55,10)::numeric) + interval '7 hours'
from satlink_video_file_metadata

where to_timestamp(substring(fpath,55,10)::numeric) between '2016-3-14' and '2016-11-6'-- 7 hours offset
where to_timestamp(substring(fpath,55,10)::numeric) between '2016-11-7' and '2017-3-11'-- 8 hours offset
where to_timestamp(substring(fpath,55,10)::numeric) between '2017-3-12' and '2017-11-4' -- 7 hours offset
where to_timestamp(substring(fpath,55,10)::numeric) between '2017-11-5' and '2018-3-10' -- 8 hours offset

set vidend_ts = vidstart_ts + interval '10 minutes'

*/


-------------------------------------------------------------------------------------------
-- Create master output table (satlink_vid_x_catch) with the columns neccessary for beta
-- version of video labels. This table is also used as input to extract frames
-------------------------------------------------------------------------------------------
/*
drop table if exists satlink_vid_x_catch;

select
    meta.id,
    meta.fpath,
    meta.fname,
    meta.vidstart_ts,
	meta.vidend_ts,
    catch.catch_ts,
    catch.sp_code, 
    catch.obstrip_id,
    lu.label_l1 as label_l1,
    lu.label_l2 as label_l2
    
into satlink_vid_x_catch

from satlink_video_file_metadata meta

-- make a fuzzy join by looking for all the catch events that fall between the video start and 10 seconds before the end time

    left join satlink_obs_catch_work catch on catch.catch_ts between meta.vidstart_ts and meta.vidstart_ts + interval '9.5 min'
    left join labels_lookup lu on lu.code = catch.sp_code
    
where  left(fpath, 15) = 'WD-WCC4E7KS5S1N'
    and (
        catch.obstrip_id = 'PALAUTUNA1TNC20161112'
        or catch.obstrip_id = 'PALAUTUNA1TNC20161212'
        or catch.obstrip_id = 'PALAUTUNA1TNC20170119'
        or catch.obstrip_id = 'PALAUTUNA1TNC20170202'
        or catch.obstrip_id = 'PALAUTUNA1TNC20170212'
        or catch.obstrip_id = 'PALAUTUNA1TNC20170220'
        or catch.obstrip_id = 'PALAUTUNA1TNC20170228'
        or catch.obstrip_id = 'PALAUTUNA1TNC20170321'
        or catch.obstrip_id = 'PALAUTUNA1TNC02170401'
        or catch.obstrip_id = 'PALAUTUNA1TNC20170704'
        )

*/

----------------------------------------------------------
-- Create final labels table for use by ~/scripts/extract
----------------------------------------------------------
/*

drop table if exists wd_wcc4e7ks5s1n_labels_v010;

select
fname as filename,
left(fname,2) as cam_num,
vidstart_ts,
catch_ts,
vidend_ts,
label_l1,
label_l2

into WD_WCC4E7KS5S1N_labels_v010
from satlink_vid_x_catch
where left(fpath, 15) = 'WD-WCC4E7KS5S1N'

*/




-------------------------------------------------------------------------------
--## create shell script to copy video files from HDDs needed for label events
-------------------------------------------------------------------------------
/*
copy 
    (
    select 'cp -v "/Volumes/' || fpath || '" "/Volumes/usbshare1-2/satlink_palau/WD-WCC4E7KS5S1N/PalauTuna1/' || fname || '"' as "#!/bin/bash"
    from satlink_vid_x_catch
    --where left(filename,27) = 'AUCF03-012455-181005_064134'
    group by fpath, fname
    )
to '/Users/mmerrifield/Projects/fishnet/scripts/copy_satlink_palautuna_vidfiles.sh'

*/

/*

select lat_e::numeric / 100 as lat
from satlink_obs_catch_work

alter table satlink_obs_catch_work
add column lat numeric (7,5),
add column lon numeric (9,5)

update satlink_obs_catch_work
set lat = lat_e::numeric / 100
set lon = lon_e::numeric / 100

set tmp_lat = split_part((split_part(lat_e, '.',3)),'(',1)
set tmp_lon = split_part((split_part(img_name, '.',2)),'(',1)

select id, catch_date::timestamp
from satlink_obs_catch_work
order by id asc

*/



