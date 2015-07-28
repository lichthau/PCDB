﻿CREATE OR REPLACE FUNCTION config_data.trg_*_nxt_id() 
RETURNS trigger AS $function$ 
	BEGIN  
		NEW.*_nxt_id :=  
			(SELECT *_id FROM config_data.*table 
			WHERE *_sdate > NEW.*_sdate 
			AND ctr_id = NEW.ctr_id 
			ORDER BY ctr_id, *_sdate ASC 
			LIMIT 1); 
	RETURN NEW; 
	END; 
$function$ LANGUAGE plpgsql;

CREATE TRIGGER trg_*_nxt_id 
	BEFORE INSERT OR UPDATE ON config_data.*table 
	FOR EACH ROW 
	EXECUTE PROCEDURE config_data.trg_*_nxt_id(); 

