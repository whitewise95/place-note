import type {
  KakaoAddressDocument,
  KakaoMapsApi,
  KakaoPlaceDocument,
} from './kakaoLoader';
import { loadKakaoMap } from './kakaoLoader';
import type { AddressSearchCandidate } from '../../types/native';

export type AddressSearch = (query: string) => Promise<AddressSearchCandidate[]>;

declare global {
  interface Window {
    PlaceNoteConfig?: {
      kakaoJavascriptKey?: string;
    };
  }
}

/**
 * React 저장 플로우에서 사용하는 기본 주소 검색 함수입니다.
 *
 * Kakao Maps JavaScript SDK의 services 라이브러리를 사용합니다.
 * - addressSearch: 도로명/지번처럼 주소 형태인 텍스트에 강합니다.
 * - keywordSearch: 장소명, 숲쉼터, 카페명처럼 주소가 아닌 텍스트에 강합니다.
 *
 * 둘을 같이 호출한 뒤 같은 주소 후보는 하나로 합쳐서 사용자에게 보여줍니다.
 */
export async function searchKakaoAddress(query: string): Promise<AddressSearchCandidate[]> {
  const kakaoJavascriptKey =
    window.PlaceNoteConfig?.kakaoJavascriptKey ?? import.meta.env.VITE_KAKAO_JAVASCRIPT_KEY ?? '';
  if (!kakaoJavascriptKey.trim()) {
    throw new Error('kakao_javascript_key_missing');
  }

  const maps = await loadKakaoMap(kakaoJavascriptKey);
  const [addressResults, placeResults] = await Promise.all([
    searchAddressDocuments(maps, query),
    searchPlaceDocuments(maps, query),
  ]);

  return dedupeCandidates([
    ...addressResults.map(addressDocumentToCandidate),
    ...placeResults.map(placeDocumentToCandidate),
  ]);
}

function searchAddressDocuments(
  maps: KakaoMapsApi,
  query: string,
): Promise<KakaoAddressDocument[]> {
  return new Promise((resolve, reject) => {
    const geocoder = new maps.services.Geocoder();
    geocoder.addressSearch(query, (documents, status) => {
      if (status === maps.services.Status.OK || status === maps.services.Status.ZERO_RESULT) {
        resolve(documents);
        return;
      }
      reject(new Error('kakao_address_search_failed'));
    });
  });
}

function searchPlaceDocuments(
  maps: KakaoMapsApi,
  query: string,
): Promise<KakaoPlaceDocument[]> {
  return new Promise((resolve, reject) => {
    const places = new maps.services.Places();
    places.keywordSearch(query, (documents, status) => {
      if (status === maps.services.Status.OK || status === maps.services.Status.ZERO_RESULT) {
        resolve(documents);
        return;
      }
      reject(new Error('kakao_place_search_failed'));
    });
  });
}

function addressDocumentToCandidate(
  document: KakaoAddressDocument,
  index: number,
): AddressSearchCandidate {
  const road = document.road_address;
  const address = document.address;
  const normalizedAddress =
    road?.address_name ?? address?.address_name ?? document.address_name;
  const regionSource = road ?? address;
  return {
    id: `address-${index}-${normalizedAddress}`,
    title: normalizedAddress,
    normalizedAddress,
    detailAddress: document.address_name,
    latitude: Number(document.y),
    longitude: Number(document.x),
    province: regionSource?.region_1depth_name,
    district: regionSource?.region_2depth_name,
    locality: regionSource?.region_3depth_name,
  };
}

function placeDocumentToCandidate(
  document: KakaoPlaceDocument,
): AddressSearchCandidate {
  const normalizedAddress = document.road_address_name || document.address_name;
  return {
    id: `place-${document.id}`,
    title: document.place_name,
    normalizedAddress,
    detailAddress: document.address_name,
    latitude: Number(document.y),
    longitude: Number(document.x),
  };
}

function dedupeCandidates(
  candidates: AddressSearchCandidate[],
): AddressSearchCandidate[] {
  const seen = new Set<string>();
  return candidates.filter((candidate) => {
    const key = `${candidate.normalizedAddress}-${candidate.latitude}-${candidate.longitude}`;
    if (seen.has(key)) {
      return false;
    }
    seen.add(key);
    return true;
  });
}
