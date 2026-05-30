# Location Filtering Notes

Place Note stores Kakao location metadata on newly resolved addresses and
derives region filters from saved `normalizedAddress` strings for older local
data without a migration.

Current filter keys:

- Province: `서울`, `경기`, `부산`
- District: `중구`, `성남시 분당구`, `해운대구`
- Locality or road: `연희동`, `삼평동`, `퇴계로`

When Kakao Map / Local API resolves an address, the local saved report stores:

- `region_1depth_name` or equivalent province value
- `region_2depth_name` / city-district value
- `region_3depth_name` / town-dong value
- road address name
- lot address name
- latitude (`y`) and longitude (`x`)

The history UI prefers structured Kakao region fields. The existing parser
remains as a fallback for older local records and OCR-only entries without
Kakao metadata. In the hybrid UI, reports with latitude and longitude show a
Kakao Maps JavaScript SDK marker in the deployed React page. React receives
its key from Vercel's `VITE_KAKAO_JAVASCRIPT_KEY` environment variable and
must run on a web origin registered in Kakao Developers.
