export default class RNKakao {
    public static login(): Promise<KakaoUser>

    public static logout(): Promise<{}>

    public static userInfo(): Promise<KakaoUser>

    public static sendKakaoMessage(sendParams: KakaoMessageParams, serverParams: any): Promise<any>
}

export interface KakaoUser {
    id: string
    accessToken: string
    nickname: string | null
    email: string | null
    profileImage: string | null
    profileImageThumbnail: string | null
    ageRange: string | null
    gender: string | null
}

export interface KakaoMessageParams {
    title: string
    description: string
    imageURL: string
    buttonMessage: string
    mobileWebURL: string
    webURL: string
    androidExecutionParams: string
    iosExecutionParams: string
}
