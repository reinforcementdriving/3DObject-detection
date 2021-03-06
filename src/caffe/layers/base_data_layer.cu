#include <vector>

#include "caffe/data_layers.hpp"

namespace caffe {

template <typename Dtype>
void BasePrefetchingDataLayer<Dtype>::Forward_gpu(
    const vector<Blob<Dtype>*>& bottom, const vector<Blob<Dtype>*>& top) {
  // First, join the thread
  JoinPrefetchThread();
  // Reshape to loaded data.
  top[0]->Reshape(this->prefetch_data_.num(), this->prefetch_data_.channels(),
      this->prefetch_data_.height(), this->prefetch_data_.width());
  // Copy the data
  caffe_copy(prefetch_data_.count(), prefetch_data_.cpu_data(),
      top[0]->mutable_gpu_data());
  if (this->output_labels_) {
    caffe_copy(prefetch_label_.count(), prefetch_label_.cpu_data(),
        top[1]->mutable_gpu_data());
  }
  // Start a new prefetch thread
  CreatePrefetchThread();
}

template <typename Dtype>
void Scene3DBasePrefetchingDataLayer<Dtype>::Forward_gpu(
  const vector<Blob<Dtype>*>& bottom, const vector<Blob<Dtype>*>& top) {
  // First, join the thread
  BasePrefetchingDataLayer<Dtype>::JoinPrefetchThread();
  // Reshape to loaded data.
  top[0]->Reshape(this->prefetch_data_.shape(0), this->prefetch_data_.shape(1),
    this->prefetch_data_.shape(2), this->prefetch_data_.shape(3), this->prefetch_data_.shape(4));
  caffe_copy(this->prefetch_data_.count(), this->prefetch_data_.gpu_data(),
    top[0]->mutable_gpu_data());

  if (this->output_labels_) {
    caffe_copy(this->prefetch_label_.count(), this->prefetch_label_.cpu_data(),
      top[1]->mutable_gpu_data());
  }

  caffe_copy(this->prefetch_bb2d_proj_.count(), this->prefetch_bb2d_proj_.cpu_data(),
    top[2]->mutable_gpu_data());
  caffe_copy(this->prefetch_attention_bb_.count(), this->prefetch_attention_bb_.cpu_data(),
    top[3]->mutable_gpu_data());

  if (this->output_bb3d_diff_)
  {
    caffe_copy(this->prefetch_bb3d_diff_.count(), this->prefetch_bb3d_diff_.cpu_data(),
      top[4]->mutable_gpu_data());
    caffe_copy(this->prefetch_bb3d_param_.count(), this->prefetch_bb3d_param_.cpu_data(),
      top[5]->mutable_gpu_data());
  }
  
  // Start a new prefetch thread
  BasePrefetchingDataLayer<Dtype>::CreatePrefetchThread();
}

INSTANTIATE_LAYER_GPU_FORWARD(BasePrefetchingDataLayer);
INSTANTIATE_LAYER_GPU_FORWARD(Scene3DBasePrefetchingDataLayer);
}  // namespace caffe
