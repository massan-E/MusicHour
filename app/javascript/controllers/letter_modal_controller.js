import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="review-modal"
export default class extends Controller {
  //ターゲットの定義
  static targets = ["letterModal", "backGround"]
  //connectメソッドは、コントローラに繋がれた時に呼ばれるアクション（モーダルが開かれた時）
  connect() {
  }
  // フォームを送信した時に発火させるアクション
  close(event) {
    // event.detail.successは、レスポンスが成功ならtrueを返します。
    // バリデーションエラー時は、falseを返します。
    if (event.detail.success) {
      //"hidden"クラスを追加し、モーダルを閉じます。
      this.backGroundTarget.classList.add("d-none");
    }
  }
  // ただただ、モーダルを閉じるアクション
  closeModal() {
    //"hidden"クラスを追加し、モーダルを閉じます。
    this.backGroundTarget.classList.add("d-none");
  }
  // モーダルの外をクリックした際に、モーダルを閉じるアクション
  closeBackground(event) {
    //アクションを呼び出しているターゲットとbackGroundTargetが同じ場合はtrueを返す。（モーダルの外をクリックしているか）
    if(event.target === this.backGroundTarget) {
      //closeModalアクションを呼び出す。
      this.closeModal();
    }
  }
}

