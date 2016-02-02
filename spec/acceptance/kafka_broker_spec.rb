require 'spec_helper_acceptance'

describe 'kafka::broker class' do
  let(:manifest) {
    <<-EOS
      include ::java
      class { 'kafka::broker':
        ensure => present,
      }
    EOS
  }

  it 'should run without errors' do
    result = apply_manifest(manifest)
    expect(result.exit_code).to eq 2
  end

#  it 'should delete accounts' do
#    grants_results = shell("mysql -e 'show grants for root@127.0.0.1;'")
#    expect(grants_results.exit_code).to eq 1
#  end

#  it 'should delete databases' do
#    show_result = shell("mysql -e 'show databases;'")
#    expect(show_result.stdout).not_to match /test/
#  end

  it 'should run a second time without changes' do
    result = apply_manifest(manifest)
    expect(result.exit_code).to eq 0
  end

end
