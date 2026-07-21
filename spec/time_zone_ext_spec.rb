require 'spec_helper'

describe TimeZoneExt do
  before(:each) do
    Time.zone = 'EST'
  end

  it "parses time with timezone specified by name" do
    Time.zone.strptime("2012-06-02 00:00 UTC", "%Y-%m-%d %H:%M %Z").to_s.should == "2012-06-01 19:00:00 -0500"
  end

  it "parses time with timezone specified by offset" do
    Time.zone.strptime("2012-06-02 00:00 +0100", "%Y-%m-%d %H:%M %z").to_s.should == "2012-06-01 18:00:00 -0500"
  end

  it "parses time without explicitly specified timezone" do
    Time.zone.strptime("2012-06-02 00:00", "%Y-%m-%d %H:%M").to_s.should == "2012-06-02 00:00:00 -0500"
  end

  it "parses time with named time zone" do
    Time.zone = "Moscow"
    Time.zone.strptime("2012-06-02 00:00", "%Y-%m-%d %H:%M").to_s.should == "2012-06-02 00:00:00 +0400"
  end

  # A backend can hand back a String instead of the expected name-list Array —
  # e.g. a "translation missing" placeholder, or i18n data overridden by a CMS
  # row. unlocalize_date_string must skip such lists rather than crash every
  # date parse (undefined method `each' for String).
  it "skips a date name list whose translation resolves to a String" do
    allow(I18n).to receive(:t).and_call_original
    allow(I18n).to receive(:t).with(:month_names, scope: "date", locale: :en)
      .and_return("translation missing: en.date.month_names")
    expect {
      Time.zone.unlocalize_date_string("04/28/2026 01:37 PM zone-05:00", :en)
    }.not_to raise_error
  end

  it "still unlocalizes with the remaining name lists when one resolves to a String" do
    allow(I18n).to receive(:t).and_call_original
    allow(I18n).to receive(:t).with(:day_names, scope: "date", locale: :en)
      .and_return("some stray cms value")
    result = Time.zone.unlocalize_date_string("June 02 2012 zone-05:00", :en)
    result.should include("2012")
  end
end
