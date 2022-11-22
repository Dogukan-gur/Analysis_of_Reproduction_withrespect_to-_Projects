--DROP VIEW [dbo].[DG_PROCESSED_SQM]
--CREATE VIEW DG_PROCESSED_SQM AS



WITH CTE1
AS(
	(SELECT *,ROW_NUMBER() OVER (PARTITION BY ID,BOM_NODE,BOM_LEVEL ORDER BY ID)  AS rn_1
	,CASE WHEN STL_BEZ LIKE 'LAM�NE 2 KAT' THEN 1 ELSE 0 END AS lmn_1
	FROM
		(SELECT *,
			CASE WHEN SUBSTRING(ID,1,1)=1 THEN 'MONOLITHIC_GLASS'
				WHEN SUBSTRING(ID,1,1)=2 THEN CASE WHEN SUBSTRING(ID,2,1)=8 THEN  'TRIPLE_IG_UNIT' ELSE 'IG_UNIT' END
				WHEN SUBSTRING(ID,1,1)=5 THEN 'MONOLITHIC_GLASS_WITH_PROCESES'
				WHEN SUBSTRING(ID,1,1)=7 THEN 'LAMI_GLASS'
				ELSE 'TEST_or_SAMPLE'
				END AS DEFF_1
	FROM
		(SELECT  Q1.ID,
				Q1.quantity,
				Q1.one_layer_m2,
				Q1.STATUS,
				Q1.customer,
				Q1.DATUM_LIEFER_TAT,
				Q1.DATUM_PROD1,
				BOM_ID,
				BOM_NODE,
				STL_BEZ,
				POS_NR,
				BOM_LEVEL
		FROM
		(
			SELECT CAST(ID AS CHAR) AS ID,
			DATUM_LIEFER_TAT,DATUM_PROD1,
			STATUS,
			CAST(SU_QM_REAL as decimal(8,2)) as one_layer_m2,
			CAST (SU_STUECK as int) as quantity,
			AH_NAME1+AH_NAME2 as customer
	
			FROM [SYSADM].[BW_AUFTR_KOPF]
			WHERE DATUM_LIEFER_TAT>'2020-01-01'
			AND DATUM_ERF>'2020-01-01'
			AND DATUM_PROD1<GETDATE()
			AND STATUS NOT IN (596,900) 
			AND STATUS>450
			AND LEN(ID)>=5
			AND LEN(ID)<7

		) AS Q1
		JOIN [SYSADM].[BW_AUFTR_STKL] STK ON Q1.ID=STK.ID
		WHERE POS_NR=1
		--AND BOM_NODE=0) 
		) AS Q2
	) AS Q3
	WHERE 
	--Q3.ID=218404 
	--AND 
	BOM_NODE=0 )
),
CTE2 
AS
	(SELECT ID,SUM(lmn_1) AS q_lmn
	FROM CTE1 
	GROUP BY ID
	)

SELECT * INTO #T1 FROM

(
SELECT 
		Q7.PRODUCT_GROUP,
		Q7.NEWDEFF,
		Q7.CUSTOMER,
		SUM(Q7.PROCESSED_SQM) AS PROCESSEDSQM
		--SUM(PROCESSED_SQM) OVER (PARTITION BY PRODUCT_GROUP,NEWDEFF,CUSTOMER ) AS rnk

		
FROM

(
	SELECT  ID AS ORDER_NUMBER
			,quantity AS TOT_ORDER_QUANTITY
			,STATUS 
			,DEFF_1 AS PRODUCT_GROUP
			--,STL_BEZ AS GLASSES
			,PROCESSED_SQM
			,one_layer_m2 AS ONE_SIDE_SQM
			,customer AS CUSTOMER
			,POS_KOMMISSION AS COMMISSION 
			,DATUM_LIEFER_TAT AS SHIPPING_DATE
			--,ROW_NUMBER() OVER (PARTITION BY ID ORDER BY ID) AS RN
			,CASE 
					WHEN DEFF_1='LAMI_GLASS' THEN 'LAMI_GLASS'
					WHEN DEFF_1='IG_UNIT' AND q_lmn=0 THEN 'IG_UNIT_PLAIN'
					WHEN DEFF_1='IG_UNIT' AND q_lmn=1 THEN 'IGWITH_1_LAMI'
					WHEN DEFF_1='IG_UNIT' AND q_lmn=2 THEN 'IGWITH_2_LAMI'
					WHEN DEFF_1='TRIPLE_IG_UNIT' AND q_lmn=0 THEN 'TRIPLE_IG_UNIT_PLAIN'
					WHEN DEFF_1='TRIPLE_IG_UNIT' AND q_lmn=1 THEN 'TRIPLE_IG_UNIT_WITH_1_LAMI'
					WHEN DEFF_1='TRIPLE_IG_UNIT' AND q_lmn=2 THEN 'TRIPLE_IG_UNIT_WITH_2_LAMI'
					WHEN DEFF_1='TRIPLE_IG_UNIT' AND q_lmn=3 THEN 'TRIPLE_IG_UNIT_WITH_3_LAMI'
					WHEN DEFF_1='MONOLITHICGLASS_WITH_PROCESES' THEN 'MONOLITHICGLASS_WITH_PROCESES'
					WHEN DEFF_1 ='MONOLITHICGLASS' THEN 'MONOLITHICGLASS'
					ELSE 'TEST_or_SAMPLE'
					END AS NEWDEFF
	FROM
	(
	
		SELECT*, CASE WHEN DEFF_1 ='MONOLITHICGLASS' THEN one_layer_m2*1 
						WHEN DEFF_1='IG_UNIT' AND q_lmn=0 THEN one_layer_m2*2
						WHEN DEFF_1='IG_UNIT' AND q_lmn=1 THEN one_layer_m2*2
						WHEN DEFF_1='IG_UNIT' AND q_lmn=2 THEN one_layer_m2*4
						WHEN DEFF_1='TRIPLE_IG_UNIT' AND q_lmn=0 THEN one_layer_m2*3
						WHEN DEFF_1='TRIPLE_IG_UNIT' AND q_lmn=1 THEN one_layer_m2*4
						WHEN DEFF_1='TRIPLE_IG_UNIT' AND q_lmn=2 THEN one_layer_m2*5
						WHEN DEFF_1='TRIPLE_IG_UNIT' AND q_lmn=3 THEN one_layer_m2*6
						WHEN DEFF_1='MONOLITHICGLASS_WITH_PROCESES' THEN one_layer_m2*1
						WHEN DEFF_1='LAMI_GLASS' THEN one_layer_m2*2
						ELSE one_layer_m2*2
						END AS PROCESSED_SQM

		FROM(
			SELECT C1.ID
					,C1.quantity
					,C1.one_layer_m2
					,C1.STATUS
					,C1.customer
					,POS.POS_KOMMISSION
					,C1.DATUM_LIEFER_TAT
					,C1.STL_BEZ
					,C1.DEFF_1
					,C1.rn_1
					,C1.lmn_1
					,C2.q_lmn
				
			FROM 
			CTE1 C1 INNER JOIN CTE2 C2 ON C1.ID=C2.ID
			LEFT JOIN [SYSADM].[BW_AUFTR_POS] AS POS ON C1.ID = POS.ID AND POS.POS_KOMMISSION <>'' AND POS.POS_NR=1
		) AS Q5
		WHERE  rn_1 =1 
	) AS Q6								
) AS Q7
GROUP BY Q7.PRODUCT_GROUP,Q7.NEWDEFF,Q7.CUSTOMER,Q7.PROCESSED_SQM


) TEMP

--DROP TABLE #T1



WITH CTETMP AS
	( SELECT SUM(PROCESSEDSQM) AS TOTSQM FROM #T1)

, CTETMP2 AS(

SELECT DISTINCT PRODUCT_GROUP,NEWDEFF,SUM(PROCESSEDSQM) OVER (PARTITION BY PRODUCT_GROUP,NEWDEFF) AS GROUPSQM
FROM #T1
GROUP BY PRODUCT_GROUP,NEWDEFF,PROCESSEDSQM

)

SELECT NQ2.PRODUCT_GROUP,NQ2.NEWDEFF,NQ2.CUSTOMER,NQ2.TOTSQMPERCUSTOMER,(NQ2.GROUPSQM/CT.TOTSQM)*100 AS PERC
FROM
	(SELECT *,RANK() OVER (PARTITION BY PRODUCT_GROUP,NEWDEFF ORDER BY TOTSQMPERCUSTOMER DESC) AS RNK
	FROM
		(SELECT DISTINCT  T.PRODUCT_GROUP,T.NEWDEFF,CUSTOMER ,SUM(PROCESSEDSQM) OVER (PARTITION BY T.CUSTOMER,T.NEWDEFF) AS TOTSQMPERCUSTOMER,CT2.GROUPSQM
		FROM #T1 AS T 
				INNER JOIN CTETMP2 AS CT2 ON T.PRODUCT_GROUP=CT2.PRODUCT_GROUP AND T.NEWDEFF=CT2.NEWDEFF	
					) AS NQ1
		) AS NQ2 CROSS JOIN CTETMP AS CT

WHERE NQ2.RNK=1
ORDER BY 5 DESC





