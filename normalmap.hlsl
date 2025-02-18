//───────────────────────────────────────
// テクスチャ＆サンプラーデータのグローバル変数定義
//───────────────────────────────────────
Texture2D g_texture : register(t0); // テクスチャー
Texture2D g_nTexture : register(t1); // ノーマルマップ用テクスチャー
SamplerState g_sampler : register(s0); // サンプラー

//───────────────────────────────────────
// コンスタントバッファ
// DirectX 側から送信されてくる、ポリゴン頂点以外の諸情報の定義
//───────────────────────────────────────
cbuffer gModel : register(b0)
{
    float4x4 matWVP; // ワールド・ビュー・プロジェクションの合成行列
    float4x4 matW; // ワールド変換マトリクス
    float4x4 matNormal; // ワールド行列
    float4 diffuseColor; // マテリアルの色＝拡散反射係数
    float4 factor;
    float4 ambientColor;
    float4 specularColor;
    float4 shininess;

    bool isTextured; // テクスチャーが貼られているかどうか
    bool isNormalMapped; // ノーマルマップが使用されているかどうか
};

cbuffer gStage : register(b1)
{
    float4 lightPosition;
    float4 eyePosition;
    float4 pLightposition;
    float4 pointLightColor[5];
    float4 spotLightColor;
    float4 direction;
    float4 kTerm[5];
    float4 sptParam;
    int4 pointListSW[5];
};

//───────────────────────────────────────
// 頂点シェーダー出力＆ピクセルシェーダー入力データ構造体
//───────────────────────────────────────
struct VS_OUT
{
    float4 pos : SV_POSITION; // 位置
    float2 uv : TEXCOORD; // UV座標
    float4 eyev : TEXCOORD4; // ワールド座標
    float4 Neyey : TEXCOORD1; // ワールド座標
    float4 normal : TEXCOORD2; // 法線
    float4 light : TEXCOORD3; // ライト座標
    float4 color : COLOR; // カラー
};

//───────────────────────────────────────
// 頂点シェーダ
//───────────────────────────────────────
VS_OUT VS(float4 pos : POSITION, float4 uv : TEXCOORD, float4 normal : NORMAL, float4 tangent : TANGENT)
{
    VS_OUT outData;
    
    // スクリーン座標に変換し、ピクセルシェーダーへ
    outData.pos = mul(pos, matWVP);
    outData.uv = uv.xy;
 
    float3 tmp = cross(tangent.xyz, normal.xyz);
    float4 binormal = mul(tmp, matNormal);
    binormal = normalize(binormal);
    normal = mul(normal, matNormal);
    normal.w = 0;
    outData.normal = normalize(normal);
    
    tangent = mul(tangent, matNormal);
    tangent.w = 0;
    tangent = normalize(tangent);
    
    float4 poaw = mul(pos, matW);
    outData.eyev = normalize(poaw - eyePosition);
    
    outData.Neyey.x = dot(outData.eyev, tangent);
    outData.Neyey.y = dot(outData.eyev, binormal);
    outData.Neyey.z = dot(outData.eyev, normal);
    outData.Neyey.w = 0;
    
    float4 light = lightPosition[0];
    light.w = 0;
    light = normalize(light);
    
    outData.light.x = dot(light, tangent);
    outData.light.y = dot(light, binormal);
    outData.light.z = dot(light, normal);
    outData.light.w = 0;
    
    outData.color = clamp(dot(outData.normal, light), 0, 1);
    
    return outData;
}

//───────────────────────────────────────
// ピクセルシェーダ
//───────────────────────────────────────
float4 PS(VS_OUT inData) : SV_Target
{
    float4 lightSource = float4(1.0, 1.0, 1.0, 1.0);
    float4 ambentSource = float4(0.2, 0.2, 0.2, 1.0);
    float4 diffuse;
    float4 ambient;
    
    if (isNormalMapped)
    {
        float4 nmap = g_nTexture.Sample(g_sampler, inData.uv) * 2.0f - 1.0f;
        nmap = normalize(nmap);
        nmap.w = 0;
        float4 NL = clamp(dot(inData.light, nmap), 0, 1);
        
        if (!isTextured)
        {
            diffuse = diffuseColor * NL * factor.x;
            ambient = diffuseColor * ambentSource * factor.x;
        }
        else
        {
            diffuse = g_texture.Sample(g_sampler, inData.uv) * NL * factor.x;
            ambient = g_texture.Sample(g_sampler, inData.uv) * ambentSource * factor.x;
        }
        
        return diffuse + ambient;
    }
    else
    {
        if (!isTextured)
        {
            diffuse = diffuseColor * inData.color * factor.x;
            ambient = diffuseColor * ambentSource * factor.x;
        }
        else
        {
            diffuse = g_texture.Sample(g_sampler, inData.uv) * inData.color * factor.x;
            ambient = g_texture.Sample(g_sampler, inData.uv) * ambentSource * factor.x;
        }
        
        return diffuse + ambient;
    }
}