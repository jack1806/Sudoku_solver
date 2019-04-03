Note: 「数独(SUDOKU)」は二コリの日本における登録商標です。


%%%%% 短い説明 %%%%%

    Cameraを接続して、sudokuvideo_fn.mの上の部分で設定を確認して、
    >> sudokuvideo_fn.m
    を実行します。数独のパズルをカメラに当てます。

    アルゴリズムに関しては、sampleprocess.mを実行。

%%%%% 長い説明 %%%%%


デモの目的:
    1. カメラから動画をとり、数独のパズルを画像処理で読み込んで、解を求める。
    2. その解のイメージを、元の画像の上に重ねて表示する。

必要なもの:

    1. ノイズの少ないweb camera
    2. ぴんとのあっている、明瞭なイメージ
    3. 大きな影がない、十分な照明

詳しい実行方法:
    まず、パズルが解けることを確認
    >> edit SUDOKU_PUZZLE1.txt
    >> mysudokusolver SUDOKU_PUZZLE1.txt

    次は、ビデオで行う：
    sudokuvideo_fn.mの中に、カメラのparameterなどを調整する必要がある可能性があります。
    (3-18行目で確認)
          >>sudokuvideo_fn.m
    を実行
    Figureを閉じるか、control-cで止める。
    万が一、メモリー不足エラーになったら、imaqresetを実行

注意：
    どのパズルでもいいというわけではありません。パズルの外の枠が明瞭であることと、
    文字のフォント特有であることに依存します。いいパズルを探す必要があります。

ファイルリスト:
1. sudokuvideo_fn.m:  メインの関数で、画像を読み込んで、前処理を行います。
2. identifynumbers_fun.m:  画像をテンプレートデータと比較すて、数値を判別します。
2. drawgraph.m:  行列 Mを受けて、sudoku_solverを呼び出して、解をテーブルに表示します。
4. sudoku_solver.m:  行列 Mを受けて, Sudokuの解を計算します
5. solution2image.m: オーバレイのための画像を作ります。
6. sudoku_fn_trace.m: solution2imageから得られた画像を、実際にオーバレイする
7. TEMPLATEDATA.mat: １－９の数値のサンプル画像