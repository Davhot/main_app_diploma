class SystemMetricStep < ApplicationRecord
  def set_attributes_system_metric_and_save(metric)
    self.count = self.count + 1

    self.cpu_average_sum = self.cpu_average_sum + metric.cpu_average
    self.cpu_average = self.cpu_average_sum / self.count

    self.memory_used_sum = self.memory_used_sum + metric.memory_used
    self.memory_used = self.memory_used_sum / self.count

    self.swap_used_sum = self.swap_used_sum + metric.swap_used
    self.swap_used = self.swap_used_sum / self.count

    self.descriptors_used_sum = self.descriptors_used_sum + metric.descriptors_used
    self.descriptors_used = self.descriptors_used_sum / self.count

    self.get_time = metric.get_time
    self.save
  end
end

class Hour < SystemMetricStep
end

class Day < SystemMetricStep
end
