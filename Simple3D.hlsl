//───────────────────────────────────────
// テクスチャ＆サンプラーデータのグローバル変数定義
//───────────────────────────────────────
Texture2D g_texture : register(t0); //テクスチャー
SamplerState g_sampler : register(s0); //サンプラー

Texture2D g_Toon_texture : register(t1); //テクスチャー
//───────────────────────────────────────
 // コンスタントバッファ
// DirectX 側から送信されてくる、ポリゴン頂点以外の諸情報の定義
//───────────────────────────────────────
cbuffer gModel : register(b0)
{
    float4x4 matWVP; // ワールド・ビュー・プロジェクションの合成行列
    float4x4 matW; //ワールド変換マトリクス
    float4x4 matNormal; // ワールド行列
    float4 diffuseColor; //マテリアルの色＝拡散反射係数tt
    float4 factor;
    float4 ambientColor;
    float4 specularColor;
    float4 shininess;

    bool isTextured; //テクスチャーが貼られているかどうか
};

cbuffer gModel : register(b1)
{
    float4 lightPosition;
    float4 eyePosition;
};

//───────────────────────────────────────
// 頂点シェーダー出力＆ピクセルシェーダー入力データ構造体
//───────────────────────────────────────
struct VS_OUT
{
    float4 wpos : POSITION0; //位置
    float4 pos : SV_POSITION; //位置
    float2 uv : TEXCOORD; //UV座標
    float4 normal : NORMAL;
    float4 eyev : POSITION1;
    float4 col : COLOR;
};

//───────────────────────────────────────
// 頂点シェーダ
//───────────────────────────────────────
VS_OUT VS(float4 pos : POSITION, float4 uv : TEXCOORD, float4 normal : NORMAL)
{
    
    VS_OUT outData = (VS_OUT) 0;

    outData.pos = mul(pos, matWVP);
    outData.uv = uv;
    normal.w = 0;
    
    normal = mul(normal, matNormal);
    normal = normalize(normal);
    outData.normal = normal;
    
    float4 light = float4(lightPosition);
    light = normalize(light);
    
    outData.col = saturate(dot(normal, light));
    float4 posw = mul(pos, matW);
    outData.eyev = eyePosition - posw;
    
    return outData;
}

//───────────────────────────────────────
// ピクセルシェーダ
//───────────────────────────────────────
float4 PS(VS_OUT inData) : SV_Target
{

    float4 lightSource = float4(1.0, 1.0, 1.0, 1.0);
    float4 diffuse;
    float4 ambient;
    
    float4 NE = dot(inData.normal.xyz, normalize(inData.eyev.xyz));
    
    float4 NL = saturate(dot(inData.normal, normalize(lightPosition)));
    
    float4 reflection = reflect(normalize(-lightPosition), inData.normal);
    float4 specular = pow(saturate(dot(reflection, normalize(inData.eyev))), shininess) * specularColor;
    float2 uv;
    uv.x = NL;
    uv.y = 0.5;
    float tI = g_Toon_texture.Sample(g_sampler, uv);
    
    if (isTextured == 0)
    {
        diffuse = lightPosition * diffuseColor * tI;
        ambient = lightPosition * diffuseColor * ambientColor;
    }
    else
    {
        diffuse = lightSource * g_texture.Sample(g_sampler, inData.uv) * tI;
        ambient = lightPosition * g_texture.Sample(g_sampler, inData.uv) * ambientColor;

    }
    
    float4 ret = diffuse + ambient;
    //if (NE > -0.1 && NE < 0.1)
    //{
    //    ret = float4(0, 0, 0, 1);
    //}

    return ret;
}