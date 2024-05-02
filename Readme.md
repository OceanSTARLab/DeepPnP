# Plug-and-Play for SSF reconstruction

This repository contains the code for the paper "Zero-Shot Reconstruction of Ocean Sound Speed Field Tensors: A Deep Plug-and-Play Approach".

## Description

You can find the FFDNet code in the `FFDNet-master` directory, which includes the pre-trained FFDNet for denoising. The `utils` folder contains various utility functions that are useful for the reconstruction process. To generate the sampled data required for reconstruction, you can use the `data_prepare.m` script. The main function for the Plug-and-Play (PnP) method is `DeepPnP.m`. For a practical demonstration of using the PnP method to reconstruct the SSF, you can refer to the `demo.m` script, which gives visualizations of the reconstructed SSF.

## Usage

To utilize the code, follow these steps:

1. Run `data_prepare.m` to generate the sampled data required for reconstruction.
2. Subsequently, execute `demo.m` to reconstruct the SSF data.

## References and Acknowledgements

The implementation is based on the following papers:

```
@article{zhang2018ffdnet,
  title={FFDNet: Toward a fast and flexible solution for CNN-based image denoising},
  author={Zhang, Kai and Zuo, Wangmeng and Zhang, Lei},
  journal={IEEE Transactions on Image Processing},
  volume={27},
  number={9},
  pages={4608--4622},
  year={2018},
  publisher={IEEE}
}
```

```
@article{zhao2020deep,
  title={Deep plug-and-play prior for low-rank tensor completion},
  author={Zhao, Xi-Le and Xu, Wen-Hao and Jiang, Tai-Xiang and Wang, Yao and Ng, Michael K},
  journal={Neurocomputing},
  volume={400},
  pages={137--149},
  year={2020},
  publisher={Elsevier}
}
```
