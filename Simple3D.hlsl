//������������������������������������������������������������������������������
// �e�N�X�`�����T���v���[�f�[�^�̃O���[�o���ϐ���`
//������������������������������������������������������������������������������
Texture2D g_texture : register(t0); //�e�N�X�`���[
SamplerState g_sampler : register(s0); //�T���v���[

Texture2D g_Toon_texture : register(t1); //�e�N�X�`���[
//������������������������������������������������������������������������������
 // �R���X�^���g�o�b�t�@
// DirectX �����瑗�M����Ă���A�|���S�����_�ȊO�̏����̒�`
//������������������������������������������������������������������������������
cbuffer gModel : register(b0)
{
    float4x4 matWVP; // ���[���h�E�r���[�E�v���W�F�N�V�����̍����s��
    float4x4 matW; //���[���h�ϊ��}�g���N�X
    float4x4 matNormal; // ���[���h�s��
    float4 diffuseColor; //�}�e���A���̐F���g�U���ˌW��tt
    float4 factor;
    float4 ambientColor;
    float4 specularColor;
    float4 shininess;

    bool isTextured; //�e�N�X�`���[���\���Ă��邩�ǂ���
};

cbuffer gModel : register(b1)
{
    float4 lightPosition;
    float4 eyePosition;
};

//������������������������������������������������������������������������������
// ���_�V�F�[�_�[�o�́��s�N�Z���V�F�[�_�[���̓f�[�^�\����
//������������������������������������������������������������������������������
struct VS_OUT
{
    float4 wpos : POSITION0; //�ʒu
    float4 pos : SV_POSITION; //�ʒu
    float2 uv : TEXCOORD; //UV���W
    float4 normal : NORMAL;
    float4 eyev : POSITION1;
    float4 col : COLOR;
};

//������������������������������������������������������������������������������
// ���_�V�F�[�_
//������������������������������������������������������������������������������
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

//������������������������������������������������������������������������������
// �s�N�Z���V�F�[�_
//������������������������������������������������������������������������������
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