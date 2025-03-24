import torch, os, random, time
import numpy as np
import torchio as tio
from torch.utils.data import DataLoader, random_split
import data, model

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

CFG={"TRAIN": True,
     "EPOCHS": 200,
     "LR": 0.0004}

def seed_everything(seed):
    random.seed(seed)
    os.environ['PYTHONHASHSEED']=str(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed(seed)
    torch.backends.cudnn.deterministic=True
    torch.backends.cudnn.benchmark=True

seed_everything(42)

tio_transform = [tio.ToCanonical(),
                 tio.transforms.RescaleIntensity(),
                 tio.Resample((1,1,1))]

data_files = tio.datasets.IXI("path/to/ixi_root",
                               modalities=('T2', 'PD'),
                               transform=tio.Compose(tio_transform),
                               download=False)

total_dataset = data.IXI_Dataset(data_files)
train_dataset, test_dataset = random_split(total_dataset, [500, 78])
train_loader, test_loader = DataLoader(train_dataset, 1), DataLoader(test_dataset, 1)

CNN_model = model.MANTIS()
CNN_model = torch.nn.DataParallel(CNN_model).to(device)
loss_fn = model.Cyclic_loss(lambda_data=0.2, lambda_cnn=1.0).to(device)
optimizer = torch.optim.Adam(CNN_model.parameters(), lr=CFG["LR"])

model_root = "E:/model_save_path/Parameter_mapping/MANTIS/"

prev_try_num = 3
curr_try_num = 4

model_prev_path = f"{model_root}{prev_try_num}.pt"
CNN_model.load_state_dict(torch.load(model_prev_path))

model_curr_path = f"{model_root}{curr_try_num}.pt"

def train_model(model, dataloader, loss_fn, optimizer, model_save_path):
    model.train()
    for epoch in range(CFG["EPOCHS"]):
        start_time = time.time()
        for i_u, gt_I0, gt_T2, dj, masks in dataloader:
            i_u, gt_I0, gt_T2, dj, masks = i_u.to("cuda"), gt_I0.to("cuda"), gt_T2.to("cuda"), dj.to("cuda"), masks.to("cuda")
            output = model(i_u)
            pred_I0, pred_T2 = output[:, 0, :, :], output[:, 1, :, :]

            loss = loss_fn(pred_I0, pred_T2, gt_I0, gt_T2, dj, masks)

            optimizer.zero_grad()
            loss.backward()
            optimizer.step()
        end_time = time.time()
        time_spent = end_time - start_time
        if (epoch%10) == 0:
            print(f"[Epoch{epoch+1}] Loss: {loss.item()}\tSpent {time_spent//60}min {time_spent%60}sec")
    torch.save(model.state_dict(), model_save_path)
    return

def test_model(model, dataloader, model_save_path):
    model.load_state_dict(torch.load(model_save_path))
    model.eval()
    test_I0, test_T2 = [], []
    for i_u, gt_I0, gt_T2, dj, masks in dataloader:    
        i_u, gt_I0, gt_T2, dj, masks = i_u.to("cuda"), gt_I0.to("cuda"), gt_T2.to("cuda"), dj.to("cuda"), masks.to("cuda")
        output = model(i_u)
        pred_I0, pred_T2 = output[:, 0, :, :], output[:, 1, :, :]

        test_I0.append(pred_I0)
        test_T2.append(pred_T2)
    return test_I0, test_T2

if CFG["TRAIN"]:
    train_model(CNN_model, train_loader, loss_fn, optimizer, model_curr_path)
else:
    test_I0, test_T2 = test_model(CNN_model, test_loader, model_curr_path)