CREATE VIEW [dbo].[FullAttributes_TransTerms]
       AS

       SELECT 
              a.[CountryISO2A],
              a.AttributeKey,
              a.Term_EnglishCulture,
              a.Term_LocalCulture

       From   

              (      SELECT 
                                  x.[CountryISO2A], 
                                  x.AttributeKey,
                                  x.Term_EnglishCulture,
                                  y.Term_LocalCulture
                     fROM ( SELECT  
                                         CountryISO2A, 
                                         b.countryid,
                                         a.[key] as AttributeKey,
                                         tt.value as Term_EnglishCulture
                                  FROM Country as b
                                  LEFT JOIN Attribute a WITH (NOLOCK) ON a.Country_Id=b.CountryId
                                  LEFT JOIN TranslationTerm as tt on tt.translation_id = a.translation_id
                                  WHERE TT.CultureCode = '2057'
                                  ) as x 
                           Join   
                                  (SELECT  
                                         CountryISO2A, 
                                         b.countryid,
                                         a.[key] as key_LocalCulture,
                                         tt.value as Term_LocalCulture
                                  FROM Country as b
                                  LEFT JOIN Attribute a WITH (NOLOCK) ON a.Country_Id=b.CountryId
                                  LEFT JOIN TranslationTerm as tt on tt.translation_id = a.translation_id
                                  WHERE TT.CultureCode = 
                                                       Case 
                                                              When CountryISO2A ='BR' then'1046'
                                                              When CountryISO2A ='CL' then'13322'
                                                              When CountryISO2A ='CR' then'5130'
                                                              When CountryISO2A ='SV' then'17418'
                                                              When CountryISO2A ='FR' then'1036'
                                                              When CountryISO2A ='GT' then'4106'
                                                              When CountryISO2A ='HN' then'18442'
                                                              When CountryISO2A ='ID' then'14345'
                                                              When CountryISO2A ='KR' then'1042'
                                                              When CountryISO2A ='MY' then'17417'
                                                              When CountryISO2A ='MX' then'2058'
                                                              When CountryISO2A ='NI' then'19466'
                                                              When CountryISO2A ='PA' then'6154'
                                                              When CountryISO2A ='PH' then'13321'
                                                              When CountryISO2A ='PT' then'2070'
                                                              When CountryISO2A ='ES' then'3082'
                                                              When CountryISO2A ='TW' then'1028'
                                                              When CountryISO2A ='TH' then'1054'
                                                              When CountryISO2A ='AE' then'2057'
                                                              When CountryISO2A ='GB' then'2057'
                                                              When CountryISO2A ='VN' then'1066'
															  When CountryISO2A ='CI' then'6156'
                                                       End
                                  ) as y on y.key_LocalCulture = x.[AttributeKey]
                                                and y.countryid = x.CountryId
                     ) as a

GO
--GRANT SELECT ON [dbo].[FullAttributes_TransTerms] TO [GPSBusiness_Full] AS [dbo]       