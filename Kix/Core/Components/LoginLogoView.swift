import SwiftUI

struct LoginLogoView: View {
    var body: some View {
        Image("LoginLogo") // 假设你的资源目录中有一张名为 "LoginLogo" 的图片
            .resizable()
            .scaledToFit()
            .frame(width: 150, height: 150)
    }
}

struct LoginLogoView_Previews: PreviewProvider {
    static var previews: some View {
        LoginLogoView()
    }
}
