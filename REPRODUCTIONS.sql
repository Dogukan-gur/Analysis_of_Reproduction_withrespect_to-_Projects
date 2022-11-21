select 
	brokenDate as Kirik_tarihi,
	brokenOrderNr AS Kýrýk_no,
	brokenOrderNr/1000 as Gorev_no ,
	brokenPosNr,
	brokenTeileNr,
	brokenStation as Kirik_istasyonu,
	brokenReason as Kirik_Sebebi,
	brokenReporter as Bildiren,
	artbez1 + artbez2 AS TANIM,
	kunde_name1 + kunde_name2 AS MUSTERÝ,
	kommission1 + kommission2 AS POZ,
	pos.breite/1000 as genislik_mm ,
	pos.hoehe/1000 as yukseklik_mm,
	((cast(pos.breite as float)/1000)*(cast(pos.hoehe as float)/1000))/1000000 as Alan_m2

from ALCIMDB.dbo.zzz_brokenGlass
RIGHT JOIN [ALCIMDB].[dbo].[pool_teile]  ON ALCIMDB.dbo.zzz_brokenGlass.brokenOrderNr=[ALCIMDB].[dbo].[pool_teile].auftnr 
INNER JOIN [ALCIMDB].[dbo].[pool_auftrag] ON ALCIMDB.dbo.zzz_brokenGlass.brokenOrderNr = [ALCIMDB].[dbo].[pool_auftrag].auftnr
INNER JOIN [ALCIMDB].[dbo].[pool_pos] pos ON ALCIMDB.dbo.zzz_brokenGlass.brokenOrderNr = pos.auftnr


where brokenDate >= '2017-01-01' 
AND opti_flag=1
order by 2 asc