#include "Stage.h"
#include "Engine/Model.h"
#include "Engine/Input.h"
#include "Engine/Camera.h"
#include "imgui/imgui.h"
#include "imgui/imgui_impl_dx11.h"
#include "imgui/imgui_impl_win32.h"

#include "Engine/Fbx.h"



void Stage::InitConstantBuffer()
{
    D3D11_BUFFER_DESC cb;
    cb.ByteWidth = sizeof(CONSTANT_BUFFER_STAGE);
    cb.Usage = D3D11_USAGE_DYNAMIC;
    cb.BindFlags = D3D11_BIND_CONSTANT_BUFFER;
    cb.CPUAccessFlags = D3D11_CPU_ACCESS_WRITE;
    cb.MiscFlags = 0;
    cb.StructureByteStride = 0;

    HRESULT hr;
    hr = Direct3D::pDevice_->CreateBuffer(&cb, nullptr, &pConstantBuffer_);
    if (FAILED(hr))
    {
        MessageBox(NULL, "�R���X�^���g�o�b�t�@�̍쐬�Ɏ��s���܂���", "�G���[", MB_OK);
    }
}

//�R���X�g���N�^
Stage::Stage(GameObject* parent)
    :GameObject(parent, "Stage"),pConstantBuffer_(nullptr),isRotate(false)
{
    hModel_ = -1;
    hGround = -1;
    hRoom_ = -1;
    hRing_ = -1;
    hRing_LambertTexture_ = -1;
    hRing_PhongCollar_ = -1;
    hRing_Lambert = -1;
}

//�f�X�g���N�^
Stage::~Stage()
{
}

//������
void Stage::Initialize()
{
    hModel_ = Model::Load("Assets\\color.fbx");
    hRoom_ = Model::Load("Assets\\room.fbx");
    hGround = Model::Load("Assets\\plane3.fbx");
    hRing_ = Model::Load("Assets\\isigaki.fbx");

    hRing_Lambert = Model::Load("Assets\\LAMBERT_RING.fbx");
    
    hRing_LambertTexture_ = Model::Load("Assets\\LAMBERT_TEXTURE_RING.fbx");
    hRing_PhongCollar_ = Model::Load("Assets\\PHONG_COLLAR_RING.fbx");
    Camera::SetPosition(XMFLOAT3{ 0, 0.8, -2.8 });
    Camera::SetTarget(XMFLOAT3{ 0,0.8,0 });

    InitConstantBuffer();
}

//�X�V
void Stage::Update()
{

    Fbx* pFbx = nullptr;
    if (isRotate)
    {
        transform_.rotate_.y += 0.5f;
    }
    if (Input::IsKey(DIK_A))
    {
        XMFLOAT4 p = Direct3D::GetLightPos();
        p = { p.x - 0.01f,p.y, p.z,p.w };
        Direct3D::SetLightPos(p);
    }
    if (Input::IsKey(DIK_D))
    {
        XMFLOAT4 p = Direct3D::GetLightPos();
        p = { p.x + 0.01f,p.y, p.z,p.w };
        Direct3D::SetLightPos(p);
    }
    if (Input::IsKey(DIK_W))
    {
        XMFLOAT4 p = Direct3D::GetLightPos();
        p = { p.x,p.y, p.z + 0.01f,p.w };
        Direct3D::SetLightPos(p);
    }
    if (Input::IsKey(DIK_S))
    {
        XMFLOAT4 p = Direct3D::GetLightPos();
        p = { p.x ,p.y, p.z - 0.01f,p.w };
        Direct3D::SetLightPos(p);
    }
    if (Input::IsKey(DIK_UP))
    {
        XMFLOAT4 p = Direct3D::GetLightPos();
        p = { p.x,p.y + 0.01f, p.z,p.w };
        Direct3D::SetLightPos(p);
    }
    if (Input::IsKey(DIK_DOWN))
    {
        XMFLOAT4 p = Direct3D::GetLightPos();
        p = { p.x ,p.y - 0.01f, p.z,p.w };
        Direct3D::SetLightPos(p);
    }

    //�R���X�^���g�o�b�t�@�̐ݒ�ƁA�V�F�[�_�[�ւ̃R���X�^���g�o�b�t�@�̃Z�b�g��������
    CONSTANT_BUFFER_STAGE cb;
    cb.lightPosition = Direct3D::GetLightPos();
    XMStoreFloat4(&cb.eyePosition, Camera::GetPosition());

    D3D11_MAPPED_SUBRESOURCE pdata;
    Direct3D::pContext_->Map(pConstantBuffer_, 0, D3D11_MAP_WRITE_DISCARD, 0, &pdata);	// GPU����̃f�[�^�A�N�Z�X���~�߂�
    memcpy_s(pdata.pData, pdata.RowPitch, (void*)(&cb), sizeof(cb));	// �f�[�^��l�𑗂�
    Direct3D::pContext_->Unmap(pConstantBuffer_, 0);	//�ĊJ

    //�R���X�^���g�o�b�t�@
    Direct3D::pContext_->VSSetConstantBuffers(1, 1, &pConstantBuffer_);	//���_�V�F�[�_�[�p	
    Direct3D::pContext_->PSSetConstantBuffers(1, 1, &pConstantBuffer_);	//�s�N�Z���V�F�[�_�[�p
}

//�`��
void Stage::Draw()
{

    Transform ltr;
    ltr.position_ = { Direct3D::GetLightPos().x,Direct3D::GetLightPos().y,Direct3D::GetLightPos().z };
    ltr.scale_ = { 0.1,0.1,0.1 };
    Model::SetTransform(hModel_, ltr);
    Model::Draw(hModel_);


    Transform tr;
    tr.position_ = { 0, 0, 0 };
    tr.scale_ = { 1.0f,1.0f,1.0f };
    tr.rotate_ = { 0,0,0 };
  /*  Model::SetTransform(hRoom_, tr);
   Model::Draw(hRoom_);*/

    //�e�N�X�`������A�t�H������
    static Transform Ring;
    Ring.scale_ = { 0.35,0.35,0.35 };
    Ring.position_ = { 0,0.5,0 };
   
    Model::SetTransform(hRing_, Ring);
    Model::Draw(hRing_);

    //�e�N�X�`���Ȃ��A�t�H������A���날��
    Ring.scale_ = { 0.35,0.35,0.35 };
    Ring.position_ = { 0.7,0.5,0 };
    
    Model::SetTransform(hRing_PhongCollar_, Ring);
    Model::Draw(hRing_PhongCollar_);

    //�����o�[�g�̂�
    Ring.scale_ = { 0.35,0.35,0.35 };
    Ring.position_ = { -0.7,0.5,0 };
  
    Model::SetTransform(hRing_Lambert, Ring);
    Model::Draw(hRing_Lambert);

    //�����o�[�g����A�e�N�X�`������
    Ring.scale_ = { 0.35,0.35,0.35 };
    Ring.position_ = { -0.7,1.2,0 };
    
    Model::SetTransform(hRing_LambertTexture_, Ring);
    Model::Draw(hRing_LambertTexture_);

    if (isRotate)
    {
        Ring.rotate_.y += 0.3;
    }


    {
        static string text;
        //ImGui::ShowDemoWindow();
        ImGui::Text("This is My Original Shader");
        ImGui::Separator();//��؂�������鎖���o����
        ImGui::Text("Stage Position%5.2lf,%5.2lf,%5.2lf", transform_.position_.x, transform_.position_.y, transform_.position_.z);

        ImGui::Checkbox("RotateSwitch", &isRotate);
        if (ImGui::Button("Rotate Light"))
        {
            isRotate = !isRotate;
        }
        ImGui::InputText("Input:", text.data(), 255);
        ImGui::Text(text.c_str());

  /*      static float pos[3] = {0,0,0};
        if (ImGui::InputFloat3("Position", pos, "%.3f"))
        {
            Ring.position_ = { pos[0],pos[1], pos[2] };
        }
        static float Scale[3] = { 0.2,0.2,0.2 };
        if(ImGui::SliderFloat3("Scale", Scale, 0,2, "%.3f"))
        {
            Ring.scale_ = { Scale[0],Scale[1], Scale[2] };
        }*/
    }

}

//�J��
void Stage::Release()
{
}