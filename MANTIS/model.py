import torch
import torch.nn as nn

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
im_size = 256

class brown_block(nn.Module):
    def __init__(self, in_channels, out_channels):
        super(brown_block, self).__init__()
        self.conv = nn.Conv2d(in_channels=in_channels, out_channels=out_channels, kernel_size=4, stride=2, padding=1)
        self.bn = nn.BatchNorm2d(out_channels)

    def forward(self, x):
        x = self.conv(x)
        x = self.bn(x)
        return x
    
class contracting_block(nn.Module):
    def __init__(self, in_channels, out_channels):
        super(contracting_block, self).__init__()
        self.conv = nn.Conv2d(in_channels=in_channels, out_channels=out_channels, kernel_size=4, stride=2, padding=1)
        self.bn = nn.BatchNorm2d(out_channels)
        self.relu = nn.ReLU(inplace=True)

    def forward(self, x):
        x = self.relu(x)
        x = self.conv(x)
        x = self.bn(x)
        return x

class expanding_block(nn.Module):
    def __init__(self, in_channels, out_channels):
        super(expanding_block, self).__init__()
        self.deconv = nn.ConvTranspose2d(in_channels=in_channels, out_channels=out_channels, kernel_size=4, stride=2, padding=1)
        self.bn = nn.BatchNorm2d(out_channels)
        self.relu = nn.ReLU(inplace=True)

    def forward(self, x):
        x = self.relu(x)
        x = self.deconv(x)
        x = self.bn(x)
        return x

class blue_block(nn.Module):
    def __init__(self, in_channels, out_channels):
        super(blue_block, self).__init__()
        self.deconv = nn.ConvTranspose2d(in_channels=in_channels, out_channels=out_channels, kernel_size=4, stride=2, padding=1)
        self.relu = nn.ReLU(inplace=True)

    def forward(self, x):
        x = self.relu(x)
        x = self.deconv(x)
        x = self.relu(x)
        return x
    
class MANTIS(nn.Module):
    def __init__(self):
        super(MANTIS, self).__init__()
        self.fusion = brown_block(8, 64)

        self.encoder1 = contracting_block(64, 128)
        self.encoder2 = contracting_block(128, 256)
        self.encoder3 = contracting_block(256, 512)
        self.encoder4 = contracting_block(512, 512)
        self.encoder5 = nn.Sequential(contracting_block(512, 512), contracting_block(512, 512)) # block 3개 하면 (1,512,1,1) -> train error (모든 채널 차원이 1이상이어야 함?)

        self.decoder1 = nn.Sequential(expanding_block(512, 512), expanding_block(512, 512))
        self.decoder2 = expanding_block(1024, 512)
        self.decoder3 = expanding_block(1024, 256)
        self.decoder4 = expanding_block(512, 128)
        self.decoder5 = expanding_block(256, 64)

        self.estimation = blue_block(128, 2)

    def _init_weights(self, m):
        if isinstance(m, nn.Conv2d) or isinstance(m, nn.Linear):
            nn.init.kaiming_normal_(m.weight, mode='fan_in', nonlinearity='relu')
            if m.bias is not None:
                nn.init.zeros_(m.bias)

    def forward(self, x):
        x_fused = self.fusion(x)

        # Encoder path
        x_en1 = self.encoder1(x_fused)
        x_en2 = self.encoder2(x_en1)
        x_en3 = self.encoder3(x_en2)
        x_en4 = self.encoder4(x_en3)
        x_en5 = self.encoder5(x_en4)

        # Decoder path
        x_de1 = self.decoder1(x_en5)
        x_de2 = self.decoder2(torch.cat((x_de1, x_en4), dim=1))
        x_de3 = self.decoder3(torch.cat((x_de2, x_en3), dim=1))
        x_de4 = self.decoder4(torch.cat((x_de3, x_en2), dim=1))
        x_de5 = self.decoder5(torch.cat((x_de4, x_en1), dim=1))

        x = self.estimation(torch.cat((x_de5, x_fused), dim=1))

        return x
    
class Cyclic_loss(nn.Module):
    def __init__(self, lambda_data=0.1, lambda_cnn=1.0):
        super(Cyclic_loss, self).__init__()
        self.lambda_data = lambda_data
        self.lambda_cnn = lambda_cnn
        self.CNN = MANTIS()
        self.mse_loss = nn.MSELoss()
    
    def forward(self, pred_I0, pred_T2, gt_I0, gt_T2, ref_kspace, masks):
        TEs = [7, 16, 25, 34, 43, 52, 62, 71]
        cnn_loss = self.mse_loss(pred_I0, gt_I0) + self.mse_loss(pred_T2, gt_T2)

        pred_I0, pred_T2 = pred_I0.squeeze(0), pred_T2.squeeze(0)
        reconstructed_kspace = [torch.fft.fftshift(torch.fft.fft2(pred_I0 * torch.exp(-1e-3*TE/pred_T2))) for TE in TEs]
        real_tensor, imag_tensor = torch.zeros((len(TEs), im_size, im_size)), torch.zeros((len(TEs), im_size, im_size))
        for ch in range(len(reconstructed_kspace)):
            real_tensor[ch] = reconstructed_kspace[ch].real
            imag_tensor[ch] = reconstructed_kspace[ch].imag
        real_masked, imag_masked = real_tensor.to(device) * masks, imag_tensor.to(device) * masks
        ref_real, ref_imag = ref_kspace.real, ref_kspace.imag
        real_loss = sum(self.mse_loss(real_k, real_masked[idx]) for idx, real_k in enumerate(ref_real))
        imag_loss = sum(self.mse_loss(imag_k, imag_masked[idx]) for idx, imag_k in enumerate(ref_imag))

        return self.lambda_data * (real_loss + imag_loss) + self.lambda_cnn * cnn_loss