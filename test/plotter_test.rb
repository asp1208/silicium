require 'tmpdir'
require 'test_helper'
require 'plotter'
require 'fileutils'

class PlotterTest < Minitest::Test
  include Silicium::Plotter

  TEMP_DIR = "#{Dir.pwd}/tmp"
  PATH_TO_TEST_RESOURCES = 'test/resources'

  SETUP = begin
            FileUtils.rm_rf(TEMP_DIR) if Dir.exist?(TEMP_DIR)
            Dir.mkdir(TEMP_DIR)
          end

  Minitest.after_run do
    FileUtils.rm_rf(TEMP_DIR)
  end

  def draw_image_and_compare(image_params, file_to_compare)
    plotter = Image.new(image_params[:width], image_params[:height])
    yield plotter

    temp_name = self.get_temp_name
    plotter.export(temp_name)

    assert FileUtils.compare_file(temp_name, File.join(PATH_TO_TEST_RESOURCES, file_to_compare))
  end

  def get_temp_name
    Dir::Tmpname.create(%w[plot .png], TEMP_DIR) {}
  end

  def test_plotter_rectangle
    draw_image_and_compare(
        {width: 100, height: 100},
        'rectangle.png') do |plotter|
      plotter.rectangle(Point.new(20, 30), 50, 60, color('black @ 0.5'))
    end
  end

  def test_bar_chart_1st_quadrant
    draw_image_and_compare(
        {width: 200, height: 100},
        'bar_chart_1st_quadrant.png') do |plotter|
      plotter.bar_chart({20 => 10, 40 => 20, 80 => 40, 160 => 80}, 1, color('red @ 1.0'))
    end
  end

  def test_bar_chart_2nd_quadrant
    draw_image_and_compare(
        {width: 200, height: 100},
        'bar_chart_2nd_quadrant.png') do |plotter|
      plotter.bar_chart({-20 => 10, -40 => 20, -80 => 40, -160 => 80}, 1, color('red @ 1.0'))
    end
  end

  def test_bar_chart_3rd_quadrant
    draw_image_and_compare(
        {width: 200, height: 100},
        'bar_chart_3rd_quadrant.png') do |plotter|
      plotter.bar_chart({-20 => -10, -40 => -20, -80 => -40, -160 => -80}, 1, color('red @ 1.0'))
    end
  end

  def test_bar_chart_4th_quadrant
    draw_image_and_compare(
        {width: 200, height: 100},
        'bar_chart_4th_quadrant.png') do |plotter|
      plotter.bar_chart({20 => -10, 40 => -20, 80 => -40, 160 => -80}, 1, color('red @ 1.0'))
    end
  end

  def test_bar_chart_1st2nd_quadrant
    draw_image_and_compare(
        {width: 200, height: 100},
        'bar_chart_1st2nd_quadrant.png') do |plotter|
      plotter.bar_chart({-20 => 10, -40 => 20, -80 => 40, -160 => 80,
                         20 => 10, 40 => 20, 80 => 40, 160 => 80}, 1, color('red @ 1.0'))
    end
  end

  def test_bar_chart_3rd4th_quadrant
    draw_image_and_compare(
        {width: 200, height: 100},
        'bar_chart_3rd4th_quadrant.png') do |plotter|
      plotter.bar_chart({-20 => -10, -40 => -20, -80 => -40, -160 => -80,
                         20 => -10, 40 => -20, 80 => -40, 160 => -80}, 1, color('red @ 1.0'))
    end
  end

  def test_bar_chart_all_quadrant
    draw_image_and_compare(
        {width: 200, height: 100},
        'bar_chart_all_quadrant.png') do |plotter|
      plotter.bar_chart({20 => -10, -40 => -20, -80 => 40, 160 => 80}, 1, color('red @ 1.0'))
    end
  end

  def test_bar_chart_exception
    plotter = Image.new(10, 10)
    assert_raises ArgumentError do
      plotter.bar_chart({20 => -10, 160 => 80}, 10, color('red @ 1.0'))
    end
  end

  def test_plotter_color_5_params
    assert_raises ArgumentError do
      color(0, 0, 0, 0, 0)
    end
  end

  def test_plotter_color_4_params
    assert_equal(color(255, 0, 0, 255), 4_278_190_335)
  end

  def test_plotter_color_3_params
    assert_equal(color(255, 0, 0), 4_278_190_335)
  end

  def test_plotter_color_2_params
    assert_equal(color('red @ 1.0', nil), 4_278_190_080)
  end

end