# 구성 목표 및 단계
- 하나의 구조를 통해 여러 형태의 구성을 관리하기 위한 코드를 작성하는 것을 목표로 한다.
- 각 단계는 terraform workspace 를 선언하고 각 일치하는 workspace 별로 정보를 저장 및 참고하는 형태를 취한다.
- 각 나열된 번호를 기준으로 클러스터 환경이 완성되는 구조이다.

1. Terraform_S3_Backend - 백엔드 관련 기본 리소스 생성

2. 00_Backend - 기본 환경 변수 관련 사항을 정의 
    ver.1 - eks_info 

3. 01_VPC
    여러 클러스터를 운영하기 위해 EKS 와의 라이프사이클을 분리하기 위한 구성
    별개로 만들고 관련 네트워크 정보를 넣어준다.
    기본적으로 필요한 요구 조건은 충족한다.
    https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/network-reqs.html

4. 02_EKS
    클러스터 생성 단계
    terraform 공식 registry 에 등록된 모듈을 활용한다.

5. 03_Addons 
    Terraform 을 helm provider와 연동하여 구성을 갖춰 blueprints의 규격을 활용한다.
