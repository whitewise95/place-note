# Location Filtering Notes

Place Note currently derives region filters from saved `normalizedAddress`
strings so existing local data can be filtered without a server migration.

Current filter keys:

- Province: `서울`, `경기`, `부산`
- District: `중구`, `성남시 분당구`, `해운대구`
- Locality or road: `연희동`, `삼평동`, `퇴계로`

When Kakao Map / Local API is enabled, keep the same UI but store structured
location fields from the Kakao response instead of relying only on text parsing:

- `region_1depth_name` or equivalent province value
- `region_2depth_name` / city-district value
- `region_3depth_name` / town-dong value
- road address name
- lot address name
- latitude (`y`) and longitude (`x`)

The existing parser should remain as a fallback for older local records and
OCR-only entries that do not have Kakao metadata.
