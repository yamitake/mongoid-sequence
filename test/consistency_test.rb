require "test_helper"

class SequenceTest < BaseTest
  def test_single_sequence_consistency
    n = 200

    n.times do |current|
      target = FirstSequencedModel.create
      assert_equal target.auto_increment , current + 1
    end

    assert_equal FirstSequencedModel.only(:auto_increment).map(&:auto_increment).sort, (1..n).to_a
  end

  def test_id_sequence_consistency
    n = 200

    n.times do |current|
      target = IdSequencedModel.create
      assert_equal target._id , current + 1
    end

    assert_equal IdSequencedModel.only(:id).map(&:id).sort, (1..n).to_a
  end

  def test_double_sequence_consistency
    n = 100

    n.times do |current|
      target1 = FirstSequencedModel.create
      assert_equal target1.auto_increment , current + 1
      target2 = SecondSequencedModel.create
      assert_equal target2.auto_increment , current + 1
    end

    assert_equal FirstSequencedModel.only(:auto_increment).map(&:auto_increment).sort, (1..n).to_a
    assert_equal SecondSequencedModel.only(:auto_increment).map(&:auto_increment).sort, (1..n).to_a
  end

  def test_prefix_sequence_consistency
    n = 100
    n.times do |current|
      target = PrefixSequencedModel.create(tenant_id: n)
      assert_equal(target.try("auto_increment") , current + 1)
      # assert_sequence_value "prefix_sequenced_model_#{n}_auto_increment", current + 1
    end

    assert_equal PrefixSequencedModel.only(:auto_increment).map(&:auto_increment).sort, (1..n).to_a
  end

  def test_embedded_sequence_consistency
    n = 100
    m = 2
    first_parent_model = ParentModel.create
    second_parent_model = ParentModel.create
    n.times do |current|
      target1 = nil
      m.times do |current_child_count|
        target1 = first_parent_model.children.create
      end
      target2 = second_parent_model.children.create
      assert_equal target1.auto_increment , (current * m) + m
      assert_equal target2.auto_increment, current + 1
    end
    assert_equal first_parent_model.children.only(:auto_increment).map(&:auto_increment).sort, (1..(n*m)).to_a
    assert_equal second_parent_model.children.only(:auto_increment).map(&:auto_increment).sort, (1..n).to_a
  end
end
