//������������������������������������������������������������������������������
 // �e�N�X�`�����T���v���[�f�[�^�̃O���[�o���ϐ���`
//������������������������������������������������������������������������������
Texture2D g_texture : register(t0); //�e�N�X�`���[
SamplerState g_sampler : register(s0); //�T���v���[
Texture2D g_nTexture : register(t1); //�m�[�}���}�b�v�e�N�X�`��
SamplerState g_nTsampler : register(s1); //�T���v���[
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
    int4 isTextured; //�e�N�X�`���[���\���Ă��邩�ǂ���
    int4 isNormalMapped; //�@���}�b�v���\���Ă��邩�ǂ���
};

cbuffer gStage : register(b1)
{
    float4 lightPosition[5];
    float4 eyePosition; //���[���h���W�ł̎��_
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
    float4 pos : SV_POSITION; //�ʒu
    float2 uv : TEXCOORD; //UV���W
    float4 eyev : POSITION; //���[���h���W�ɕϊ����ꂽ�����x�N�g��
    float4 Neyev : POSITION1; //�m�[�}���}�b�v�p�̐ڋ�Ԃɕϊ����ꂽ�����x�N�g��
    float4 normal : NORMAL; //�@���x�N�g��
    float4 light : POSITION2; //���C�g��ڋ�Ԃɕϊ������x�N�g��
    float4 color : COLOR; //�����o�[�g�̊g�U���ˌv�Z�p
};

//������������������������������������������������������������������������������
// ���_�V�F�[�_
//������������������������������������������������������������������������������
VS_OUT VS(float4 pos : POSITION, float4 uv : TEXCOORD, float4 normal : NORMAL, float4 tangent : TANGENT)
{
	//�s�N�Z���V�F�[�_�[�֓n�����
    VS_OUT outData;

	//���[�J�����W�ɁA���[���h�E�r���[�E�v���W�F�N�V�����s���������
	//�X�N���[�����W�ɕϊ����A�s�N�Z���V�F�[�_�[��
    outData.pos = mul(pos, matWVP);
    outData.uv = uv.xy;
    //�ڐ�A�@���A�]�@�����v�Z���āA���[�J�����W�ɕϊ�
    float3 tmp = cross(tangent.xyz, normal.xyz);
    //tmp.w = 0;
    float4 binormal = mul(tmp, matNormal);
    binormal = normalize(binormal); //�]�@�������[�J�����W�ɕϊ��������
    normal = mul(normal, matNormal); //�@�������[�J�����W�ɕϊ��������
    normal.w = 0;
    outData.normal = normalize(normal);
    
    tangent = mul(tangent, matNormal);
    tangent.w = 0;
    tangent = normalize(tangent);
    
    //�����x�N�g���i���[���h���W�j
    float4 posw = mul(pos, matW);
    outData.eyev = float4(normalize(eyePosition.xyz - posw.xyz), 0); //���[���h���W�̎����x�N�g��
    
    //�����x�N�g����ڋ�Ԃɕϊ�
    outData.Neyev.x = dot(outData.eyev, tangent);
    outData.Neyev.y = dot(outData.eyev, binormal);
    outData.Neyev.z = dot(outData.eyev, normal);
    outData.Neyev.w = 0;
    
	//float4 light = float4(0, 1, -1, 0);
    //float4 light = lightPosition[0];
    float4 light = pLightposition;
    light.w = 0;
    light = normalize(light);
    //���C�g��ڋ�Ԃɕϊ�
    outData.light.x = mul(light, tangent);
    outData.light.y = mul(light, binormal);
    outData.light.z = mul(light, normal);
    outData.light.w = 0;
    
    outData.color = clamp(dot(outData.normal, light), 0, 1);

	//�܂Ƃ߂ďo��
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
    if (isNormalMapped.x == 1)
    { //�m�[�}���}�b�v�摜�̓ǂݍ���
        float4 nmap = g_nTexture.Sample(g_nTsampler, inData.uv) * 2.0f - 1.0f;
        nmap = normalize(nmap);
        nmap.w = 0;
        inData.light.w = 0;
        inData.Neyev.w = 0;
        //�����o�[�g�̂��
        float4 NL = clamp(dot(normalize(inData.light), nmap), 0, 1);
        //���ʔ��˂̌v�Z
        float4 reflection = reflect(normalize(inData.light), nmap);
        float4 specular = pow(clamp(dot(normalize(reflection), normalize(inData.Neyev)), 0, 1), shininess);
        
        if (isTextured.x == 0)
        {
            diffuse = diffuseColor * NL * factor.x;
            ambient = diffuseColor * ambentSource * factor.x;
        }
        else
        {
            diffuse = g_texture.Sample(g_sampler, inData.uv) * NL * factor.x;
            ambient = g_texture.Sample(g_sampler, inData.uv) * ambentSource;

        }

        return diffuse + 0.5f * specular + ambient;

    }
    else
    {
        
        if (isTextured.x == 0)
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