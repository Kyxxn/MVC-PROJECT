### MVC-PROJECT
> MVC 아키텍처로 프로젝트 해보기

<br>

## 📖 프로젝트 학습 목표
- Model에서의 `struct`와 `class` 선택 고민하기
  - 모델에서 왜 struct로 사용하는게 좋은지 고민하기
- MVC를 왜 안 쓰는지 대답할 수 있게 MVC 한계 파악하기
- MVC의 명령형 방식을 이해하고, 선언형 방식과 차이 생각하기
- MVC를 대체하는 아키텍처를 왜 사용하는지 MVC와 비교하여 이해해보기

<br>

## 🏃🏻 프로젝트에서의 경험
<details>
  <summary>프로젝트 시작 전, 내가 생각하는 MVC 한계</summary>
  <br>
  지금껏 내가 MVC 구조로 작성한 코드들을 생각해봤을 때의 MVC 장단점을 정리해보겠다.
  
  이 프로젝트가 끝났을 때, 이 내용과 비교해보면 좋을 거 같다.
  
  <br>
  
  장점
  
  - 비교적 다른 아키텍처에 비해 전체적인 코드를 적게 작성해도 된다.
  - 빠른 시간 내에 구현할 수 있다.

  <br>
  
  단점

  - MVC의 C, 컨트롤러의 코드가 매우 길어진다.
  - 컨트롤러가 명령을 하는 방식으로, 컨트롤러가 무거워져서 유지보수가 낮아진다.
  - 뷰와 컨트롤러 사이의 결합도가 높아, 확장성이 떨어지게 된다.
</details>


<details>
  <summary>프로젝트 간, 궁금했던 점들</summary>
  <br>
  
  ### 모델을 만들 때 처음부터 추상화를 해야할까 ?
  > 본 프로젝트에서는 '사각형', '사진', '텍스트', '원'과 같이 Shape들이 등장한다.

  > 그러나 처음에는 사각형만 필요로 하고, 점차 한 개씩 추가되는 방식인데..
  
  > 그렇다면 처음 '사각형'을 만들 때부터 추상화를 하는 게 맞을까 ?


  ### 추상화는 어디까지 해야 할까 ?
  > 본 프로젝트에서는 '사각형', '사진', '텍스트', '원'과 같이 Shape들이 등장한다.

  > 그리고 각각의 Shape에 대한 팩토리를 만들어서 OCP 원칙을 따르게 할 것이다. 이를 구현하기 위해 ShapeCretable 프로토콜로 추상화를 해주었다. 아래는 코드이다.

  ``` swift
  protocol ShapeCreatable {
      associatedtype ShapeType: (Shapable & AlphaControllable)
      
      func makeShape() -> ShapeType
  }
  ```
  
  위와 같이 `ShapeCretable`을 만들게 되면 `Rectangle`은 문제가 없으나, `Photo`의 경우 imageURL을 받아야 하므로 문제가 생기게 된다.

  PhotoFactory에만 `func makeShape(imageURL: URL) -> Photo {}`을 만들고 컨트롤러에서 타입캐스팅을 해서 처리하는게 좋을까,
  
  아니면 불필요한 메소드라도 `ShapeCreatable`에 넣어두는게 편할까?

</details>