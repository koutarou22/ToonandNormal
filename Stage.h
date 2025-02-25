#pragma once
#include "Engine/GameObject.h"

#pragma once
#include "Engine/GameObject.h"

namespace
{
    const int POINT_LIGHT_MAX{ 5 };
}


struct CONSTBUFFER_STAGE
{
    XMFLOAT4 pointlightPosition[POINT_LIGHT_MAX];  //�_�����ʒu�ő�5��
    XMFLOAT4 eyePosition;    //���_�̈ʒu
    XMFLOAT4 sptLightPosition; //�X�|�b�g���C�g�̈ʒu
    XMFLOAT4 pointLightColor[POINT_LIGHT_MAX];
    XMFLOAT4 sptLightColor;
    XMFLOAT4 direction;
    XMFLOAT4 kTerm[POINT_LIGHT_MAX];
    XMFLOAT4 sptLightparam;
    XMINT4 pointListSW[POINT_LIGHT_MAX];//�_�����̃X�C�b�`
};

struct spotLightState
{
    XMFLOAT4 LightPosition;
    XMFLOAT4 color;
    XMFLOAT4 direction;
    float theta;//theta phi<---<---theta--->--->phi
    float phi;//phi phi<---<---theta--->--->phi
    float att;
    float toff;
};

struct pointLightState
{
    XMFLOAT4 lightPosition;
    XMFLOAT4 pointLightColor;
    XMFLOAT4 kTerm;
    int sw;
};

//���������Ǘ�����N���X
class Stage : public GameObject
{
    int hModel_;    //���f���ԍ�
    int hRoom_;
    int hGround;
    int hRing_;//�ŏ��̓z
    int hRing_LambertTexture_;//�e�N�X�`������@phong�Ȃ��̃g�[���X(lambert)
    int hRing_PhongCollar_;//�e�N�X�`���Ȃ��Aphong����A�F����
    int hRing_Lambert;//�e�N�X�`���Ȃ��Alambert�̂�

    bool isRotate;
    ID3D11Buffer* pCBStage_;
    //ID3D11Buffer* pCBSpot_;
    void InitConstantBuffer();
    spotLightState sptlight_;
    pointLightState ptlight_[POINT_LIGHT_MAX];

public:
    //�R���X�g���N�^
    Stage(GameObject* parent);

    //�f�X�g���N�^
    ~Stage();

    //������
    void Initialize() override;

    //�X�V
    void Update() override;

    //�`��
    void Draw() override;

    //�J��
    void Release() override;
};