require 'apache-vhosts-parser'

describe 'Parser' do
	it 'should find one virtualhost' do
		str = <<-eos
			<VirtualHost>
				ServerName localhost
			</VirtualHost>
		eos

		conf = ApacheVhostsParser.parseString(str)
		expect(conf.vhosts.count).to be 1
	end

	it 'should find one virtualhost with *:80 as addresses' do
		str = <<-eos
			<VirtualHost *:80>
				ServerName localhost
			</VirtualHost>
		eos

		res = ApacheVhostsParser.parseString(str)
		expect(res.vhosts.count).to be 1
		expect(res.vhosts.first[:addresses]).to eq [{host: '*', port: 80}]
	end

	it 'should find one virtualhost with *:80 and 127.0.0.1:8080 as addresses' do
		str = <<-eos
			<VirtualHost *:80 127.0.0.1:8080 1.2.3.4>
				ServerName localhost
			</VirtualHost>
		eos

		res = ApacheVhostsParser.parseString(str)
		expect(res.vhosts.count).to be 1
		expect(res.vhosts.first[:addresses]).to eq [
			{host: '*', port: 80},
			{host: '127.0.0.1', port: 8080},
			{host: '1.2.3.4', port: nil}
		]
	end

	it 'should find one virtualhost with servername localhost' do
		str = <<-eos
			<VirtualHost>
				ServerName localhost
			</VirtualHost>
		eos

		res = ApacheVhostsParser.parseString(str)
		expect(res.vhosts.count).to be 1
		expect(res.vhosts.first[:server_name]).to eq 'localhost'
	end

	it 'should find 2 virtualhosts' do
		str = <<-eos
			<VirtualHost>
				ServerName localhost
			</VirtualHost>

			<VirtualHost>
				ServerName example.com
			</VirtualHost>
		eos

		res = ApacheVhostsParser.parseString(str)
		expect(res.vhosts.count).to be 2
		expect(res.vhosts.first[:server_name]).to eq 'localhost'
		expect(res.vhosts.last[:server_name]).to eq 'example.com'
	end

	it 'should find one virtualhost with document root /var/www/example.com' do
		str = <<-eos
			<VirtualHost>
				DocumentRoot /var/www/example.com
				ServerName localhost
			</VirtualHost>
		eos

		res = ApacheVhostsParser.parseString(str)
		expect(res.vhosts.count).to be 1
		expect(res.vhosts.first[:document_root]).to eq '/var/www/example.com'
	end

	it 'should find the URL for /var/www/example.com to be example.com' do
		str = <<-eos
			<VirtualHost>
				DocumentRoot /var/www/example.com
				ServerName example.com
			</VirtualHost>
		eos

		res = ApacheVhostsParser.parseString(str)
		expect(res.urlFor '/var/www/example.com').to eq 'example.com'
	end
end
