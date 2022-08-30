SELECT 
	CASE FULLTEXTSERVICEPROPERTY('IsFullTextInstalled')
		WHEN 1 THEN 'Full-Text Search is enabled' 
		ELSE 'Full-Text Search is not enabled' 
	END
;