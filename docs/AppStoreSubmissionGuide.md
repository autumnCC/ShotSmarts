# App Store 提交指南 / App Store Submission Guide

## 中文指南

### 准备工作

1. **确保应用功能完整**
   - 测试所有功能是否正常工作
   - 检查所有界面在不同屏幕尺寸下的显示

2. **准备App Store所需素材**
   - 应用图标(1024x1024px)
   - 应用截图(需要多种设备尺寸)
   - 应用描述
   - 关键词
   - 隐私政策URL

### 构建和导出应用

1. **在Xcode中构建应用**
   - 打开Xcode项目
   - 确保"Signing & Capabilities"配置正确
   - 选择"Product" > "Archive"

2. **导出应用**
   - 存档完成后，Xcode Organizer窗口会自动打开
   - 选择最新的存档，点击"Distribute App"
   - 选择"App Store Connect"，点击"Next"
   - 选择发布选项，通常选择"Upload"
   - 选择分发证书和配置文件，然后点击"Next"
   - 核对信息后点击"Upload"

### 在App Store Connect中配置应用

1. **创建应用记录**
   - 登录[App Store Connect](https://appstoreconnect.apple.com)
   - 点击"My Apps"，然后点击"+"
   - 填写应用信息:
     - 中文市场名称: 光影指南
     - 其他市场名称: ShotSmarts
     - Bundle ID: 与Xcode项目中相同
     - SKU: 唯一标识符

2. **添加应用详情**
   - 上传截图和应用图标
   - 填写应用描述、关键词
   - 设置分类(照片与视频)
   - 添加隐私政策URL
   - 设置价格和可用地区

3. **关联构建版本**
   - 等待上传的构建版本在"TestFlight"标签中显示
   - 在"App Store"标签中选择该构建版本
   - 完成"App Review Information"部分
   - 点击"Save"后点击"Submit for Review"

## English Guide

### Preparation

1. **Ensure App Functionality is Complete**
   - Test all features to ensure they work correctly
   - Check all interfaces on different screen sizes

2. **Prepare App Store Assets**
   - App icon (1024x1024px)
   - Screenshots (multiple device sizes required)
   - App description
   - Keywords
   - Privacy policy URL

### Build and Export App

1. **Build App in Xcode**
   - Open Xcode project
   - Ensure "Signing & Capabilities" is configured correctly
   - Select "Product" > "Archive"

2. **Export App**
   - After archiving completes, Xcode Organizer window will open automatically
   - Select the latest archive and click "Distribute App"
   - Choose "App Store Connect" and click "Next"
   - Choose distribution options, typically select "Upload"
   - Select distribution certificate and provisioning profile, then click "Next"
   - Review information and click "Upload"

### Configure App in App Store Connect

1. **Create App Record**
   - Log in to [App Store Connect](https://appstoreconnect.apple.com)
   - Click "My Apps" and then click "+"
   - Fill in app information:
     - Chinese market name: 光影指南
     - Other markets name: ShotSmarts
     - Bundle ID: Same as in Xcode project
     - SKU: A unique identifier

2. **Add App Details**
   - Upload screenshots and app icon
   - Fill in app description, keywords
   - Set category (Photos & Video)
   - Add privacy policy URL
   - Set pricing and available regions

3. **Associate Build**
   - Wait for uploaded build to appear in "TestFlight" tab
   - Select that build in "App Store" tab
   - Complete "App Review Information" section
   - Click "Save" then "Submit for Review"

## 日本語ガイド

### 準備

1. **アプリの機能が完全であることを確認**
   - すべての機能が正しく動作することをテスト
   - 異なる画面サイズですべてのインターフェースを確認

2. **App Store素材の準備**
   - アプリアイコン (1024x1024px)
   - スクリーンショット（複数のデバイスサイズが必要）
   - アプリの説明
   - キーワード
   - プライバシーポリシーURL

### アプリのビルドとエクスポート

1. **Xcodeでアプリをビルド**
   - Xcodeプロジェクトを開く
   - "Signing & Capabilities"が正しく設定されていることを確認
   - "Product" > "Archive"を選択

2. **アプリのエクスポート**
   - アーカイブが完了すると、Xcode Organizerウィンドウが自動的に開きます
   - 最新のアーカイブを選択し、"Distribute App"をクリック
   - "App Store Connect"を選び、"Next"をクリック
   - 配布オプションを選択、通常は"Upload"を選択
   - 配布証明書とプロビジョニングプロファイルを選択し、"Next"をクリック
   - 情報を確認し、"Upload"をクリック

### App Store Connectでのアプリ設定

1. **アプリレコードの作成**
   - [App Store Connect](https://appstoreconnect.apple.com)にログイン
   - "My Apps"をクリックし、次に"+"をクリック
   - アプリ情報を入力:
     - 中国市場名: 光影指南
     - その他の市場名: ShotSmarts
     - Bundle ID: Xcodeプロジェクトと同じ
     - SKU: ユニークな識別子

2. **アプリ詳細の追加**
   - スクリーンショットとアプリアイコンをアップロード
   - アプリの説明、キーワードを入力
   - カテゴリを設定（写真＆ビデオ）
   - プライバシーポリシーURLを追加
   - 価格と利用可能地域を設定

3. **ビルドの関連付け**
   - アップロードしたビルドが"TestFlight"タブに表示されるのを待つ
   - "App Store"タブでそのビルドを選択
   - "App Review Information"セクションを完成させる
   - "Save"をクリックしてから"Submit for Review"をクリック 