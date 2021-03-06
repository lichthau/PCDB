﻿CREATE OR REPLACE VIEW config_data.view_lhelc_lsq
AS
SELECT lhelc_id, lhelc_lsq_computed
FROM
	(SELECT lhelc_id FROM config_data.lh_election) AS LH_ELECTIONS
LEFT OUTER JOIN
	(SELECT lhelc_id, sqrt(0.5*SUM(pty_vts_sts_square))::DOUBLE PRECISION AS lhelc_lsq_computed
		FROM
			(SELECT lhelc_id, pty_id, 
				(pty_lh_vts_shr - pty_lh_sts_shr)^2.0 AS pty_vts_sts_square
				FROM
					(SELECT lhelc_id, pty_id, pty_lh_sts_shr
						FROM	
							(SELECT lhelc_id, lh_id FROM config_data.lower_house) AS LH_LHELC
						JOIN
							(SELECT lh_id, pty_id, 
								100*MAX(SEATS.pty_lh_sts_computed
								/SEATS_TOTAL.lhelc_sts_ttl_computed) AS pty_lh_sts_shr
								FROM
									(SELECT lh_id, 
										NULLIF(SUM(pty_lh_sts_computed),0)::NUMERIC 
											AS lhelc_sts_ttl_computed
										FROM config_data.view_pty_lh_sts_computed
										GROUP BY lh_id 
									) AS SEATS_TOTAL
								JOIN
									(SELECT lh_id, pty_id, pty_lh_sts_computed::NUMERIC
										FROM config_data.view_pty_lh_sts_computed
									WHERE pty_id 
									NOT IN 
										(SELECT DISTINCT pty_id 
											FROM config_data.party 
											WHERE pty_abr LIKE 'Other'
										) 
									) AS SEATS
								USING(lh_id)
								WHERE pty_lh_sts_computed > 0 AND pty_lh_sts_computed IS NOT NULL
								GROUP BY lh_id, pty_id
							) AS SEAT_SHR_IN_LH
						USING(lh_id)
					) AS SEAT_SHR
				JOIN
					(SELECT lhelc_id, pty_id, 
						100*MAX(VOTES.pty_lh_vts
						/VOTES_TOTAL.lhelc_vts_ttl) AS pty_lh_vts_shr
						FROM
							(SELECT lhelc_id, 
								SUM(COALESCE(pty_lh_vts_pr,0) 
								+ COALESCE(pty_lh_vts_pl,0))::NUMERIC 
									AS lhelc_vts_ttl
								FROM config_data.lh_vote_results 
								GROUP BY lhelc_id 
								ORDER BY lhelc_id
							) AS VOTES_TOTAL
						JOIN
							(SELECT lhelc_id, pty_id, 
								(COALESCE(pty_lh_vts_pr,0) 
								+ COALESCE(pty_lh_vts_pl,0))::NUMERIC 
									AS pty_lh_vts
								FROM config_data.lh_vote_results
							) AS VOTES
						USING(lhelc_id)
						WHERE pty_lh_vts > 0 AND pty_lh_vts IS NOT NULL
						GROUP BY lhelc_id, pty_id
					) AS VOTES_SHR
				USING(lhelc_id, pty_id) 
				ORDER BY lhelc_id, pty_id
			) AS VOTE_SEAT_SQARES
		WHERE lhelc_id 
		NOT IN 
			(SELECT DISTINCT lhelc_id
			FROM  
				(SELECT * FROM
					(SELECT lhelc_id, pty_id, pty_lh_sts_pr, pty_lh_sts_pl 
						FROM
							(SELECT lhelc_id, lh_id 
								FROM config_data.lower_house
							) AS LH_LHELC
						JOIN
							(SELECT lh_id, pty_id, pty_lh_sts_pr, pty_lh_sts_pl 
								FROM config_data.lh_seat_results
							) AS SEAT_RESULTS
						USING(lh_id)
					) AS LH_SEATS
				JOIN
					(SELECT pty_id, pty_abr 
						FROM config_data.party
					) AS PARTIES 
				USING(pty_id)
				) AS SEATS
			JOIN
				(SELECT * FROM
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
			)
		GROUP BY lhelc_id
	) AS VALID_LSQs
	USING(lhelc_id)
ORDER BY lhelc_id;