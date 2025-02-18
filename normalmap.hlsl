//������������������������������������������������������������������������������
// �e�N�X�`�����T���v���[�f�[�^�̃O���[�o���ϐ���`
//������������������������������������������������������������������������������
Texture2D g_texture : register(t0); // �e�N�X�`���[
Texture2D g_nTexture : register(t1); // �m�[�}���}�b�v�p�e�N�X�`���[
SamplerState g_sampler : register(s0); // �T���v���[

//������������������������������������������������������������������������������
// �R���X�^���g�o�b�t�@
// DirectX �����瑗�M����Ă���A�|���S�����_�ȊO�̏����̒�`
//������������������������������������������������������������������������������
cbuffer gModel : register(b0)
{
    float4x4 matWVP; // ���[���h�E�r���[�E�v���W�F�N�V�����̍����s��
    float4x4 matW; // ���[���h�ϊ��}�g���N�X
    float4x4 matNormal; // ���[���h�s��
    float4 diffuseColor; // �}�e���A���̐F���g�U���ˌW��
    float4 factor;
    float4 ambientColor;
    float4 specularColor;
    float4 shininess;

    bool isTextured; // �e�N�X�`���[���\���Ă��邩�ǂ���
    bool isNormalMapped; // �m�[�}���}�b�v���g�p����Ă��邩�ǂ���
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

//������������������������������������������������������������������������������
// ���_�V�F�[�_�[�o�́��s�N�Z���V�F�[�_�[���̓f�[�^�\����
//������������������������������������������������������������������������������
struct VS_OUT
{
    float4 pos : SV_POSITION; // �ʒu
    float2 uv : TEXCOORD; // UV���W
    float4 eyev : TEXCOORD4; // ���[���h���W
    float4 Neyey : TEXCOORD1; // ���[���h���W
    float4 normal : TEXCOORD2; // �@��
    float4 light : TEXCOORD3; // ���C�g���W
    float4 color : COLOR; // �J���[
};

//������������������������������������������������������������������������������
// ���_�V�F�[�_
//������������������������������������������������������������������������������
VS_OUT VS(float4 pos : POSITION, float4 uv : TEXCOORD, float4 normal : NORMAL, float4 tangent : TANGENT)
{
    VS_OUT outData;
    
    // �X�N���[�����W�ɕϊ����A�s�N�Z���V�F�[�_�[��
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

//������������������������������������������������������������������������������
// �s�N�Z���V�F�[�_
//������������������������������������������������������������������������������
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