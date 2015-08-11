//
//  GameViewController.m
//  NKGLKit3DCube
//
//  Created by nanoka____ on 2015/08/05.
//  Copyright (c) 2015年 nanoka____. All rights reserved.
//

#import "GameViewController.h"
#import <OpenGLES/ES2/glext.h>

//バッファ上のデータ位置を返す
#define BUFFER_OFFSET(i) ((char *)NULL + (i))

//3Dオブジェクトのデータ
GLfloat gCubeVertexData[216] = {
//        頂点座標              法線ベクトルの情報
//   X座標, Y座標, Z座標,      向きX,  向きY, 向きZ,
     0.5f, -0.5f, -0.5f,     1.0f,  0.0f,  0.0f, //右下
     0.5f,  0.5f, -0.5f,     1.0f,  0.0f,  0.0f, //右上
     0.5f, -0.5f,  0.5f,     1.0f,  0.0f,  0.0f, //左下 右
     0.5f, -0.5f,  0.5f,     1.0f,  0.0f,  0.0f, //左下 側
     0.5f,  0.5f, -0.5f,     1.0f,  0.0f,  0.0f, //右上
     0.5f,  0.5f,  0.5f,     1.0f,  0.0f,  0.0f, //左上
    
     0.5f,  0.5f, -0.5f,     0.0f,  1.0f,  0.0f, //右上
    -0.5f,  0.5f, -0.5f,     0.0f,  1.0f,  0.0f, //左上
     0.5f,  0.5f,  0.5f,     0.0f,  1.0f,  0.0f, //右下 上
     0.5f,  0.5f,  0.5f,     0.0f,  1.0f,  0.0f, //右下 側
    -0.5f,  0.5f, -0.5f,     0.0f,  1.0f,  0.0f, //左上
    -0.5f,  0.5f,  0.5f,     0.0f,  1.0f,  0.0f, //左下
    
    -0.5f,  0.5f, -0.5f,    -1.0f,  0.0f,  0.0f, //左上
    -0.5f, -0.5f, -0.5f,    -1.0f,  0.0f,  0.0f, //左下
    -0.5f,  0.5f,  0.5f,    -1.0f,  0.0f,  0.0f, //右上 左
    -0.5f,  0.5f,  0.5f,    -1.0f,  0.0f,  0.0f, //右上 側
    -0.5f, -0.5f, -0.5f,    -1.0f,  0.0f,  0.0f, //左下
    -0.5f, -0.5f,  0.5f,    -1.0f,  0.0f,  0.0f, //右下
    
    -0.5f, -0.5f, -0.5f,     0.0f, -1.0f,  0.0f, //左下
     0.5f, -0.5f, -0.5f,     0.0f, -1.0f,  0.0f, //右下
    -0.5f, -0.5f,  0.5f,     0.0f, -1.0f,  0.0f, //左上 下
    -0.5f, -0.5f,  0.5f,     0.0f, -1.0f,  0.0f, //左上 側
     0.5f, -0.5f, -0.5f,     0.0f, -1.0f,  0.0f, //右下
     0.5f, -0.5f,  0.5f,     0.0f, -1.0f,  0.0f, //右上
    
     0.5f,  0.5f,  0.5f,     0.0f,  0.0f,  1.0f, //右上
    -0.5f,  0.5f,  0.5f,     0.0f,  0.0f,  1.0f, //左上
     0.5f, -0.5f,  0.5f,     0.0f,  0.0f,  1.0f, //右下 前
     0.5f, -0.5f,  0.5f,     0.0f,  0.0f,  1.0f, //右下 側
    -0.5f,  0.5f,  0.5f,     0.0f,  0.0f,  1.0f, //左上
    -0.5f, -0.5f,  0.5f,     0.0f,  0.0f,  1.0f, //左下
    
     0.5f, -0.5f, -0.5f,     0.0f,  0.0f, -1.0f, //左下
    -0.5f, -0.5f, -0.5f,     0.0f,  0.0f, -1.0f, //右下
     0.5f,  0.5f, -0.5f,     0.0f,  0.0f, -1.0f, //左上 奥
     0.5f,  0.5f, -0.5f,     0.0f,  0.0f, -1.0f, //左上 側
    -0.5f, -0.5f, -0.5f,     0.0f,  0.0f, -1.0f, //右下
    -0.5f,  0.5f, -0.5f,     0.0f,  0.0f, -1.0f  //左下
};

/*========================================================
 ; GameViewController
 ========================================================*/
@implementation GameViewController {
    float _rotation; //3Dオブジェクトの回転の角度
    EAGLContext *context; //コンテキスト(状態を保持する)
    GLuint _vertexArray; //テクスチャ
    GLuint _vertexBuffer; //3Dオブジェクトデータのバッファ
    GLKBaseEffect *effect; //エフェクト(GLKitでのシェーダーの代わり)
}

/*--------------------------------------------------------
 ; dealloc : 解放
 ;      in :
 ;     out :
 --------------------------------------------------------*/
-(void)dealloc {
    //OpenGL ESの後処理
    [self tearDownGL];
    
    //OpenGL ES関数が編集中のコンテキストが自分のコンテキストの時
    if ([EAGLContext currentContext] == context) {
        //nilを設定して解除する
        [EAGLContext setCurrentContext:nil];
    }
}

/*--------------------------------------------------------
 ; viewDidLoad : 初回Viewが読み込まれた時
 ;          in :
 ;         out :
 --------------------------------------------------------*/
-(void)viewDidLoad {
    [super viewDidLoad];
    
    //コンテキストをOpenGL ES 2.0で描画できる状態に変更
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!context) {
        //EAGLContextクラスの生成に失敗した時にログを出力
        NSLog(@"Failed to create ES context");
    }
    
    //自身のUIViewをGLKViewに変換
    GLKView *view = (GLKView *)self.view;
    //自身のUIViewでOpenGL ES 2.0での描画ができる状態に変更
    view.context = context;
    //描画精度を設定、メモリ使用量もここで調節
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    //OpenGLのセットアップ
    [self setupGL];
}

/*--------------------------------------------------------
 ; setupGL : OpenGLのセットアップ
 ;      in :
 ;     out :
 --------------------------------------------------------*/
-(void)setupGL {
    //このスレッドで今からコンテキストを変更することを宣言。
    [EAGLContext setCurrentContext:context];
    
    //3Dで発生する物体のZ座標のメモリを初期化(描画前に必須)
    glEnable(GL_DEPTH_TEST);
    
    //テクスチャにIDが1を割り振る
    glGenVertexArraysOES(1, &_vertexArray);
    //テクスチャの表示状態の保存場所をメモリ上に確保
    glBindVertexArrayOES(_vertexArray);
    
    //1個のバッファ(データ保存場所)を生成。バッファに1以上の一意な整数のハンドルを割り振る
    glGenBuffers(1, &_vertexBuffer);
    //バッファが頂点座標指定の3Dデータということを宣言
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    //バッファに3Dデータを入れる
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    
    //頂点座標指定での描画を許可する
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    //バッファの各頂点の位置情報は3つで型はfloat型、自動正規はオフ、データの先頭位置は0、データ間の間隔は24バイトで設定
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    //通常の頂点の属性配列を使用
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    //バッファの各頂点の通常情報は3つで型はfloat型、自動正規はオフ、データの先頭位置は12、データ間の間隔は24バイトで設定
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
    
    //頂点アレイの結合を解除
    glBindVertexArrayOES(0);
    
    //エフェクトの初期化
    effect = [[GLKBaseEffect alloc] init];
    //証明をONにする
    effect.light0.enabled = GL_TRUE;
    //証明の色を設定
    effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
}

/*--------------------------------------------------------
 ; tearDownGL : OpenGLの後処理
 ;         in :
 ;        out :
 --------------------------------------------------------*/
-(void)tearDownGL {
    //このスレッドで今からコンテキストを変更することを宣言。
    [EAGLContext setCurrentContext:context];
    
    //バッファのデータ保存場所を削除する
    glDeleteBuffers(1, &_vertexBuffer);
    //テクスチャの表示状態のメモリ上の保存場所を削除する
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    //エフェクトを初期化
    effect = nil;
}

#pragma mark - GLKView and GLKViewController delegate methods
/*========================================================
 ; GLKViewController
 ========================================================*/
/*--------------------------------------------------------
 ; update : OpenGLでの再描画のタイミングで呼ばれる
 ;     in :
 ;    out :
 --------------------------------------------------------*/
-(void)update {
    //前回画面を更新してからの経過時間の半分の数値だけ_rotationの角度を大きくする
    _rotation += self.timeSinceLastUpdate * 0.5f;
    
    //自身の横/縦の比率を入れる
    float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
    //3D空間の中央から65離れた位置から撮影、0.1〜100までの距離にある物体を描画(認識)し、描画時の比率は画面の比率を基準にするカメラの情報を設定
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    //baseModelViewMatrixにx座標0.0,y座標0.0,z座標-4.0の3D座標情報を入れる
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
    //baseModelViewMatrixにy方向に_rotationの角度の回転をさせる処理を追加する
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
    
    //modelViewMatrixにx座標0.0,y座標0.0,z座標-1.5の3D座標情報を入れる
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -0.5f);
    //modelViewMatrixにx方向,y方向,z方向に_rotationの角度の回転をさせる処理を追加する
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    
    //modelViewMatrixにbaseModelViewMatrixを基準としたmodelViewMatrixが結合されたGLKMatrix4を入れる
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    //射影(カメラ)座標にprojectionMatrixを設定
    effect.transform.projectionMatrix = projectionMatrix;
    
    //モデルビュー(ここではCubeのオブジェクト)座標にmodelViewMatrixを設定
    effect.transform.modelviewMatrix = modelViewMatrix;
}

/*--------------------------------------------------------
 ; glkView:drawInRect : OpenGLでの描画処理
 ;                 in : view(GLKView)
 ;                    : rect(CGRect)
 ;                out :
 --------------------------------------------------------*/
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    //背景色を赤165.75,緑165.75,青165.75の灰色で透明度なしで色を設定
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    //glClearColor()で指定した色で画面全体を塗りつぶす
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //_vertexArrayのメモリ上の表示状態の保存場所を設定
    glBindVertexArrayOES(_vertexArray);

    //今から使用するエフェクトを宣言(エフェクトを有効にする)
    [effect prepareToDraw];
    
    //描き方は三角形を並べる方式で36個の頂点がある有効になっているエフェクトを0番目から描画する
    glDrawArrays(GL_TRIANGLES, 0, 36);
}

@end
