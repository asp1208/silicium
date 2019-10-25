require 'test_helper'
require 'silicium_test'
require 'graph'

class GraphTest < SiliciumTest
  include Silicium::Graphs

  def test_default_constructor
    g = OrientedGraph.new
    assert_equal(g.vertex_number, 0)
  end

  def test_advanced_constructor
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    assert_equal(g.vertex_number, 3)

    assert(g.has_vertex?(0))
    assert(g.has_vertex?(:one))
    assert(g.has_vertex?('two'))

    assert(g.has_edge?(0, :one))
    assert(g.has_edge?(:one, 0))
    assert(g.has_edge?(:one, 'two'))
    assert(g.has_edge?('two', 0))
    assert(g.has_edge?('two', 'two'))
  end

  def test_add_vertex
    g = OrientedGraph.new
    g.add_vertex!(:one)
    assert_equal(g.vertex_number, 1)
    assert(g.has_vertex?(:one))

    g.add_vertex!(:two)
    assert_equal(g.vertex_number, 2)
    assert(g.has_vertex?(:one))
    assert(g.has_vertex?(:two))
  end

  def test_add_edge
    g = OrientedGraph.new([{v: 0,     i: []},
                           {v: :one,  i: []},
                           {v: 'two', i: []}])

    g.add_edge!(0, :one)

    assert(g.has_edge?(0, :one))
    assert(!g.has_edge?(:one, 0))
  end

  def test_adjacted_with
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    assert_equal(g.adjacted_with(:one), [0, 'two'].to_set)
  end

  def test_adjacted_with_can_not_change_graph
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])
    g.adjacted_with(0) << 'two'

    assert(!g.has_edge?(0, 'two'))
  end

  def test_label_edge
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.label_edge!(0, :one, :some_label)
    assert_equal(g.get_edge_label(0, :one), :some_label)
  end

  def test_label_vertex
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.label_vertex!(:one, :some_label)
    assert_equal(g.get_vertex_label(:one), :some_label)
  end

  def test_delete_vertex_with_label
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    assert_equal(g.vertex_label_number,0)
    g.label_vertex!(0, :some_label)
    assert_equal(g.get_vertex_label(0), :some_label)
    assert_equal(g.vertex_label_number,1)

    assert_equal(g.vertex_number, 3)
    assert(g.has_vertex?(0))
    g.delete_vertex!(0)
    assert(!g.has_vertex?(0))
    assert_equal(g.vertex_number, 2)

    assert_equal(g.vertex_label_number,0)
    exception = assert_raises(GraphError) do
      g.get_vertex_label(0)
    end
    assert_match(/Graph does not contain vertex/, exception.message)

  end

  def test_delete_vertex_with_label_and_edge_label_1
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.label_edge!(:one, 'two', 'label')
    assert_equal(g.get_edge_label(:one, 'two'), 'label')

    g.label_edge!('two', 0, 1)
    assert_equal(g.get_edge_label('two', 0), 1)

    g.label_edge!('two', 'two', [666,666,666])
    assert_equal(g.get_edge_label('two', 'two'), [666,666,666])

    assert_equal(g.edge_label_number,3)

    assert_equal(g.vertex_label_number,0)
    g.label_vertex!('two', :label)
    assert_equal(g.get_vertex_label('two'), :label)
    assert_equal(g.vertex_label_number,1)

    assert_equal(g.vertex_number, 3)
    assert(g.has_vertex?('two'))
    g.delete_vertex!('two')
    assert(!g.has_vertex?('two'))
    assert_equal(g.vertex_number, 2)

    assert_equal(g.vertex_label_number,0)
    exception = assert_raises(GraphError) do
      g.get_vertex_label('two')
    end
    assert_match(/Graph does not contain vertex/, exception.message)

    assert_equal(g.edge_label_number,0)

    exception = assert_raises(GraphError) do
      g.get_edge_label(:one, 'two')
    end
    assert_match(/Graph does not contain edge/, exception.message)

    exception = assert_raises(GraphError) do
      g.get_edge_label('two', 0)
    end
    assert_match(/Graph does not contain edge/, exception.message)

    exception = assert_raises(GraphError) do
      g.get_edge_label('two', 'two')
    end
    assert_match(/Graph does not contain edge/, exception.message)

  end

  def test_delete_vertex_with_label_and_edge_label_2
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.label_edge!(0, :one, {'Flex' => :Ricardo_Milos})
    assert_equal(g.get_edge_label(0, :one), {'Flex' => :Ricardo_Milos})

    g.label_edge!(:one, 0, 2.82)
    assert_equal(g.get_edge_label(:one, 0), 2.82)

    g.label_edge!(:one, 'two', :ьыь)
    assert_equal(g.get_edge_label(:one, 'two'), :ьыь)

    assert_equal(g.edge_label_number,3)

    assert_equal(g.vertex_label_number,0)
    g.label_vertex!(:one, 'Эчпочмак')
    assert_equal(g.get_vertex_label(:one), 'Эчпочмак')
    assert_equal(g.vertex_label_number,1)

    assert_equal(g.vertex_number, 3)
    assert(g.has_vertex?(:one))
    g.delete_vertex!(:one)
    assert(!g.has_vertex?(:one))
    assert_equal(g.vertex_number, 2)

    assert_equal(g.vertex_label_number,0)
    exception = assert_raises(GraphError) do
      g.get_vertex_label(:one)
    end
    assert_match(/Graph does not contain vertex/, exception.message)

    assert_equal(g.edge_label_number,0)

    exception = assert_raises(GraphError) do
      g.get_edge_label(0, :one)
    end
    assert_match(/Graph does not contain edge/, exception.message)

    exception = assert_raises(GraphError) do
      g.get_edge_label(:one, 0)
    end
    assert_match(/Graph does not contain edge/, exception.message)

    exception = assert_raises(GraphError) do
      g.get_edge_label(:one, 'two')
    end
    assert_match(/Graph does not contain edge/, exception.message)

  end



  def test_delete_vertex_single_1
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.delete_vertex!(0)

    pred = !g.has_vertex?(0) and g.vertex_number == 2
    assert(pred)

  end

  def test_delete_vertex_single_2
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.delete_vertex!(:one)

    pred = !g.has_vertex?(:one) and g.vertex_number == 2
    assert(pred)

  end

  def test_delete_vertex_single_3
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.delete_vertex!('two')

    pred = !g.has_vertex?('two') and g.vertex_number == 2
    assert(pred)

  end

  def test_delete_vertex_single_4
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.delete_vertex!(0)
    g.delete_vertex!(:one)

    pred = !g.has_vertex?(0) and !g.has_vertex?(:one) and g.vertex_number == 1
    assert(pred)

  end

  def test_delete_vertex_single_5
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.delete_vertex!(:one)
    g.delete_vertex!('two')

    pred = !g.has_vertex?(:one) and !g.has_vertex?('two') and g.vertex_number == 1
    assert(pred)

  end

  def test_delete_vertex_single_6
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.delete_vertex!(0)
    g.delete_vertex!('two')

    pred = !g.has_vertex?(0) and !g.has_vertex?('two') and g.vertex_number == 1
    assert(pred)

  end

  def test_delete_vertex_single_7
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.delete_vertex!(0)
    g.delete_vertex!(:one)
    g.delete_vertex!('two')

    pred = !g.has_vertex?(0) and !g.has_vertex?(:one) and !g.has_vertex?('two') and g.vertex_number == 0
    assert(pred)
  end








  def test_delete_vertex_and_check_edges_1
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])
    g.delete_vertex!(0)

    pred = !g.has_edge?(0, :one) and !g.has_edge?(:one, 0) and !g.has_edge?('two', 0) and g.vertex_number == 2
    assert(pred)

  end

  def test_delete_vertex_and_check_edges_2
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.delete_vertex!(:one)

    pred = !g.has_edge?(0, :one) and !g.has_edge?(:one, 0) and !g.has_edge?(:one, 'two') and g.vertex_number == 2
    assert(pred)

  end

  def test_delete_vertex_and_check_edges_3
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.delete_vertex!('two')

    pred = !g.has_edge?(:one, 'two') and !g.has_edge?('two', 0) and !g.has_edge?('two', 'two') and g.vertex_number == 2
    assert(pred)

  end

  def test_delete_vertex_and_check_edges_4
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.delete_vertex!(0)
    g.delete_vertex!(:one)

    pred = !g.has_edge?(0, :one) and !g.has_edge?(:one, 0) and !g.has_edge?('two', 0) and !g.has_edge?(:one, 'two') and g.vertex_number == 1
    assert(pred)

  end

  def test_delete_vertex_and_check_edges_5
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.delete_vertex!(:one)
    g.delete_vertex!('two')

    pred = !g.has_edge?(0, :one) and !g.has_edge?(:one, 0) and !g.has_edge?(:one, 'two') and !g.has_edge?('two', 'two') and g.vertex_number == 1
    assert(pred)

  end

  def test_delete_vertex_and_check_edges_6
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])


    g.delete_vertex!(0)
    g.delete_vertex!('two')

    pred = !g.has_edge?(0, :one) and !g.has_edge?(:one, 0) and !g.has_edge?('two', 0) and !g.has_edge?(:one, 'two') and !g.has_edge?('two', 'two') and g.vertex_number == 1
    assert(pred)

  end

  def test_delete_vertex_and_check_edges_7
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.delete_vertex!(0)
    assert(!g.has_vertex?(0))
    assert(!g.has_edge?(0, :one))
    assert(!g.has_edge?(:one, 0))
    assert(!g.has_edge?('two', 0))

    g.delete_vertex!(:one)
    assert(!g.has_vertex?(:one))
    assert(!g.has_edge?(:one, 'two'))

    g.delete_vertex!('two')
    assert(!g.has_vertex?('two'))
    assert(!g.has_edge?('two', 'two'))
    assert_equal(g.vertex_number, 0)

  end






  def test_delete_edge_1
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.delete_edge!(0, :one)
    assert(!g.has_edge?(0, :one))
    assert_equal(g.edge_number, 4)

  end

  def test_delete_edge_2
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.delete_edge!(:one, 0)
    assert(!g.has_edge?(:one, 0))
    assert_equal(g.edge_number, 4)

  end

  def test_delete_edge_3
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.delete_edge!(:one, 'two')
    assert(!g.has_edge?(:one, 'two'))
    assert_equal(g.edge_number, 4)

  end

  def test_delete_edge_4
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.delete_edge!('two', 0)
    assert(!g.has_edge?('two', 0))
    assert_equal(g.edge_number, 4)

  end

  def test_delete_edge_5
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.delete_edge!('two', 'two')
    assert(!g.has_edge?('two', 'two'))
    assert_equal(g.edge_number, 4)
  end

  def test_delete_edge_6
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.delete_edge!(0, :one)
    assert(!g.has_edge?(0, :one))

    g.delete_edge!(:one, 0)
    assert(!g.has_edge?(:one, 0))
    assert_equal(g.edge_number, 3)
  end

  def test_delete_edge_7
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])


    g.delete_edge!(0, :one)
    assert(!g.has_edge?(0, :one))

    g.delete_edge!(:one, 'two')
    assert(!g.has_edge?(:one, 'two'))
    assert_equal(g.edge_number, 3)
  end

  def test_delete_edge_8
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.delete_edge!(0, :one)
    assert(!g.has_edge?(0, :one))

    g.delete_edge!('two', 0)
    assert(!g.has_edge?('two', 0))
    assert_equal(g.edge_number, 3)

  end

  def test_delete_edge_9
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.delete_edge!(0, :one)
    assert(!g.has_edge?(0, :one))

    g.delete_edge!('two', 'two')
    assert(!g.has_edge?('two', 'two'))
    assert_equal(g.edge_number, 3)

  end

  def test_delete_edge_10
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.delete_edge!(:one, 0)
    assert(!g.has_edge?(:one, 0))

    g.delete_edge!(:one, 'two')
    assert(!g.has_edge?(:one, 'two'))
    assert_equal(g.edge_number, 3)

  end

  def test_delete_edge_11
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.delete_edge!(:one, 0)
    assert(!g.has_edge?(:one, 0))

    g.delete_edge!('two', 0)
    assert(!g.has_edge?('two', 0))
    assert_equal(g.edge_number, 3)
  end

  def test_delete_edge_12
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])


    g.delete_edge!(:one, 0)
    assert(!g.has_edge?(:one, 0))

    g.delete_edge!('two', 'two')
    assert(!g.has_edge?('two', 'two'))
    assert_equal(g.edge_number, 3)
  end

  def test_delete_edge_13
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.delete_edge!(:one, 'two')
    assert(!g.has_edge?(:one, 'two'))

    g.delete_edge!('two', 0)
    assert(!g.has_edge?('two', 0))
    assert_equal(g.edge_number, 3)
  end

  def test_delete_edge_14
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.delete_edge!(:one, 'two')
    assert(!g.has_edge?(:one, 'two'))

    g.delete_edge!('two', 'two')
    assert(!g.has_edge?('two', 'two'))
    assert_equal(g.edge_number, 3)
  end

  def test_delete_edge_15
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.delete_edge!('two', 0)
    assert(!g.has_edge?('two', 0))

    g.delete_edge!('two', 'two')
    assert(!g.has_edge?('two', 'two'))
    assert_equal(g.edge_number, 3)
  end

  def test_delete_edge_16
    g = OrientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.delete_edge!(0, :one)
    assert(!g.has_edge?(0, :one))

    g.delete_edge!(:one, 0)
    assert(!g.has_edge?(:one, 0))

    g.delete_edge!(:one, 'two')
    assert(!g.has_edge?(:one, 'two'))

    g.delete_edge!('two', 0)
    assert(!g.has_edge?('two', 0))

    g.delete_edge!('two', 'two')
    assert(!g.has_edge?('two', 'two'))
    assert_equal(g.edge_number, 0)

  end




  def test_unoriented_add_edge
    g = UnorientedGraph.new([{v: 0,     i: []},
                           {v: :one,  i: []},
                           {v: 'two', i: []}])

    g.add_edge!(0, :one)

    assert(g.has_edge?(0, :one))
    assert(g.has_edge?(:one, 0))
  end

  def test_unoriented_label_edge
    g = UnorientedGraph.new([{v: 0,     i: [:one]},
                           {v: :one,  i: [0,'two']},
                           {v: 'two', i: [0, 'two']}])

    g.label_edge!(0, :one, :some_label)
    assert_equal(g.get_edge_label(0, :one), :some_label)
    assert_equal(g.get_edge_label(:one, 0), :some_label)
  end
end

def test_delete_unoriented_vertex_single_1
  g = UnorientedGraph.new([{v: 0,     i: [:one]},
                         {v: :one,  i: [0,'two']},
                         {v: 'two', i: [0, 'two']}])

  g.delete_vertex!(0)
  assert(!g.has_vertex?(0))
  assert_equal(g.vertex_number, 2)

end

def test_delete_unoriented_vertex_single_2
  g = UnorientedGraph.new([{v: 0,     i: [:one]},
                         {v: :one,  i: [0,'two']},
                         {v: 'two', i: [0, 'two']}])

  g.delete_vertex!(:one)
  assert(!g.has_vertex?(:one))
  assert_equal(g.vertex_number, 2)

end

def test_delete_unoriented_vertex_single_3
  g = UnorientedGraph.new([{v: 0,     i: [:one]},
                         {v: :one,  i: [0,'two']},
                         {v: 'two', i: [0, 'two']}])

  g.delete_vertex!('two')
  assert(!g.has_vertex?('two'))
  assert_equal(g.vertex_number, 2)

end

def test_delete_unoriented_vertex_single_4
  g = UnorientedGraph.new([{v: 0,     i: [:one]},
                         {v: :one,  i: [0,'two']},
                         {v: 'two', i: [0, 'two']}])

  g.delete_vertex!(0)
  assert(!g.has_vertex?(0))

  g.delete_vertex!(:one)
  assert(!g.has_vertex?(:one))
  assert_equal(g.vertex_number, 1)

end

def test_delete_unoriented_vertex_single_5
  g = UnorientedGraph.new([{v: 0,     i: [:one]},
                         {v: :one,  i: [0,'two']},
                         {v: 'two', i: [0, 'two']}])

  g.delete_vertex!(:one)
  assert(!g.has_vertex?(:one))

  assert_equal(g.vertex_number, 2)

  g.delete_vertex!('two')
  assert(!g.has_vertex?('two'))
  assert_equal(g.vertex_number, 1)

end

def test_delete_unoriented_vertex_single_6
  g = UnorientedGraph.new([{v: 0,     i: [:one]},
                         {v: :one,  i: [0,'two']},
                         {v: 'two', i: [0, 'two']}])

  g.delete_vertex!(0)
  assert(!g.has_vertex?(0))

  assert_equal(g.vertex_number, 2)

  assert(g.has_vertex?('two'))
  g.delete_vertex!('two')
  assert(!g.has_vertex?('two'))

  assert_equal(g.vertex_number, 1)

end

def test_delete_unoriented_vertex_single_7
  g = UnorientedGraph.new([{v: 0,     i: [:one]},
                         {v: :one,  i: [0,'two']},
                         {v: 'two', i: [0, 'two']}])

  g.delete_vertex!(0)
  assert(!g.has_vertex?(0))

  g.delete_vertex!(:one)
  assert(!g.has_vertex?(:one))

  g.delete_vertex!('two')
  assert(!g.has_vertex?('two'))
  assert_equal(g.vertex_number, 0)
end