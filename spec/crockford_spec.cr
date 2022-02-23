require "./spec_helper"

describe Crockford do
  it "encodes" do
    Crockford.encode(32).should eq("10")
    Crockford.encode(123).should eq("3V")
    Crockford.encode(1234).should eq("16J")
    Crockford.encode(5111).should eq("4ZQ")
    Crockford.encode(65535).should eq("1ZZZ")
    Crockford.encode(123456789012).should eq("3JZ9J6GM")
  end

  it "decodes" do
    Crockford.decode("OI").should eq(1)
    Crockford.decode("3V").should eq(123)
    Crockford.decode("3v").should eq(123)
    Crockford.decode("16J").should eq(1234)
    Crockford.decode("16j").should eq(1234)
    Crockford.decode("4ZQ").should eq(5111)
    Crockford.decode("3JZ9J6GM").should eq(123456789012)
    Crockford.decode("3G923-0VQVS").should eq(123456789012345)
    Crockford.decode("3g923-0vqvs").should eq(123456789012345)
  end

  it "handles zero" do
    Crockford.encode(0).should eq("0")
    Crockford.decode("0").should eq(0)
    Crockford.decode("00").should eq(0)
  end

  it "#encode raises when given a negative number" do
    expect_raises(ArgumentError, "Unable to encode negative values.") do
      Crockford.encode(-5)
    end
  end

  it "#decode? returns nil when invalid chars found" do
    Crockford.decode?("!").should be_nil
    Crockford.decode?("_").should be_nil
  end

  it "#decode raises when invalid chars found" do
    expect_raises(ArgumentError, "Unable to decode ordinal #{'!'.ord}.") do
      Crockford.decode("!")
    end

    expect_raises(ArgumentError, "Unable to decode ordinal 95.") do
      Crockford.decode("_")
    end
  end

  it "x -> encode -> decode -> x" do
    random = Random.new
    10000.times do
      v = random.rand(0_i64..Int64::MAX)
      e = Crockford.encode(v)
      d = Crockford.decode(e)
      d.should eq(v)
    end
  end
end
