import torch, random, math
import numpy as np
from torch.utils.data import Dataset
import torchvision.transforms as transforms

im_size = 256

class IXI_Dataset(Dataset):
    def __init__(self, total_data, resize=True):
        self.total_data = total_data
        self.resize = resize
    
    def __len__(self):
        return len(self.total_data)
    
    def __get_multiecho__(self, I0, T2):
        TEs = [7, 16, 25, 34, 43, 52, 62, 71]  # milli-sec (from MANTIS paper)
        return [I0 * torch.exp(-1e-3*x/T2) for x in TEs]
    
    def __concat__(self, I0, T2):
        output = None
        images = self.__get_multiecho__(I0, T2)
        for im in images:
            tensor = im.unsqueeze(0)
            if output is None:
                output = tensor
            else:
                output = torch.concatenate((output, tensor), dim=0)
        
        return output
    
    def __1D_variable_masks__(self, undersampling_rate=3, num_echos=8):
        echo_masks = torch.zeros(num_echos, im_size, im_size)
        for echo in range(num_echos):
            total = list(range(0, im_size))
            num_cols_to_sample = math.ceil(im_size / undersampling_rate)
            center = im_size // 2
            center_width = math.ceil(num_cols_to_sample / 3)
            center_mask = list(range(center-center_width//2, center+center_width//2))

            peripheral = [x for x in total if x not in center_mask]
            random.shuffle(peripheral)
            noncenter_masks = peripheral[:num_cols_to_sample-center_width]
            undersampling_columns = sorted(center_mask + noncenter_masks)

            mask = torch.zeros((im_size, im_size))
            for col in undersampling_columns:
                mask[:, col] = torch.ones(im_size)
            echo_masks[echo] = mask
        
        return echo_masks
        
    def __undersampling__(self, echo_images, masks):
        num_echoes, _, _ = echo_images.shape
        undersampled_real, undersampled_imag = torch.empty_like(echo_images), torch.empty_like(echo_images)
        undersampled_echo_images = torch.empty_like(echo_images)
        for echo in range(num_echoes):
            curr_echo_im = echo_images[echo]
            curr_echo_kspace = torch.fft.fftshift(torch.fft.fft2(curr_echo_im, norm="ortho")) # Fully-sampled
            real_masked, imag_masked = curr_echo_kspace.real * masks[echo], curr_echo_kspace.imag * masks[echo]
            undersampled_real[echo] = real_masked
            undersampled_imag[echo] = imag_masked
            curr_dj = torch.view_as_complex(torch.stack((real_masked, imag_masked), dim=-1))
            undersampled_echo_images[echo] = torch.abs(torch.fft.ifft2(torch.fft.ifftshift(curr_dj), norm="ortho"))
        undersampled_kspace = torch.view_as_complex(torch.stack((undersampled_real, undersampled_imag), dim=-1))
        return undersampled_kspace, undersampled_echo_images
    
    def __getitem__(self, index):
        subject = self.total_data[index]
        ref_I0 = subject['PD'].data[0][:, :, 80]
        ref_T2 = subject['T2'].data[0][:, :, 80]
        if self.resize == True:
            resize = transforms.Resize((im_size, im_size))
            ref_I0 = resize(ref_I0.unsqueeze(0).unsqueeze(0)).squeeze(0).squeeze(0)
            ref_T2 = resize(ref_T2.unsqueeze(0).unsqueeze(0)).squeeze(0).squeeze(0)
        multiecho_images = self.__concat__(ref_I0, ref_T2)  # (8, 256, 256)
        echo_masks = self.__1D_variable_masks__(undersampling_rate=3, num_echos=8)
        ref_kspace, i_u = self.__undersampling__(multiecho_images, echo_masks)
        return i_u.to(torch.float32), ref_I0.to(torch.float32), ref_T2.to(torch.float32), ref_kspace, echo_masks.to(torch.float32) # GPU 연산에 float64(double)이나 int형은 비효율적