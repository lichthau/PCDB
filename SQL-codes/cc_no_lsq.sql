﻿CREATE OR REPLACE VIEW config_data.cc_no_lsq
AS
SELECT DISTINCT lhelc_id
	FROM  
		(SELECT * 
			FROM
				(SELECT lhelc_id, pty_id, pty_lh_sts_pr, pty_lh_sts_pl
					FROM
						(SELECT lh_id, lhelc_id FROM config_data.lower_house) AS LH
					JOIN
						(SELECT lh_id, pty_id, pty_lh_sts_pr, pty_lh_sts_pl 
							FROM config_data.lh_seat_results
						) AS LH_SEATS
					USING(lh_id)
				) AS LH_SEATS
			JOIN
				(SELECT pty_id, pty_abr 
					FROM config_data.party
				) AS PARTIES 
			USING(pty_id)
		) AS SEATS
	JOIN
		(SELECT * 
			FROM
				(SELECT lhelc_id, pty_id, pty_lh_vts_pr, pty_lh_vts_pl 
					FROM config_data.lh_vote_results
				) AS LH_SEATS
			JOIN
				(SELECT pty_id, pty_abr 
					FROM config_data.party
				) AS PARTIES 
			USING(pty_id)
		) AS VOTES
	USING(lhelc_id, pty_id)
	WHERE pty_lh_vts_pr IS NULL 
		AND pty_lh_vts_pl IS NULL 
		AND VOTES.pty_abr NOT LIKE '%Other' 
	OR pty_lh_sts_pr IS NULL 
		AND pty_lh_sts_pl IS NULL 
		AND SEATS.pty_abr NOT LIKE '%Other' 
ORDER BY lhelc_id;
