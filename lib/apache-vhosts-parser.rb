module ApacheVhostsParser

	class Config
		attr_reader :vhosts


		def initialize tag
			@tag = tag

			@vhosts = @tag[:children].keep_if do |child|
				child[:name] == 'virtualhost'
			end.each do |vhost|

				vhost[:addresses] = vhost[:arguments].map do |hp|
					host, port = hp.split(':')
					{
						host: host,
						port: port ? port.to_i : nil
					}
				end

				(vhost[:children] || []).each do |nested|
					if nested[:type] == 'directive'
						case nested[:name]
						when 'servername'
							vhost[:server_name] = nested[:arguments].first
						when 'documentroot'
							vhost[:document_root] = nested[:arguments].first
						end
					end
				end
			end
		end

		def urlFor dir
			vhosts.each do |h|
				if h[:document_root] == dir
					return h[:server_name]
				end
			end
			return nil
		end
	end

	def self.parseString str
		vhosts = []

		tag = {
			children: []
		}

		str.split(/\n+/).map(&:strip).each do |line|
			if line =~ /^$/
				#ignore the line
			elsif m = line.match(/<\s*(\w+)(.*?)>$/)
				opener, rest = m[1], m[2].to_s.strip.split(/\s+/)
				new_tag = {
					name: opener.downcase,
					type: 'tag',
					original_name: opener,
					arguments: rest,
					parent: tag,
					children: []
				}
				tag[:children] << new_tag
				tag = new_tag
			elsif closer = line[/<\/\s*(\w+)>$/, 1]
				if closer.downcase == tag[:name]
					tag = tag[:parent]
				else
					throw "Mismatched closing tag: #{closer} for #{tag[:original_name]}"
				end
			else
				directive, *arguments = line.split(/\s+/)
				tag[:children] << {
					name: directive.downcase,
					arguments: arguments,
					type: 'directive',
					original_name: directive,
					parent: tag
				}
			end
		end

		return Config.new(tag)
	end

	def self.parseDirectory dir='/etc/apache2/sites-enabled/'
		parseString Dir.glob(File.join(dir, '*')).map(&File.method(:read)).join "\n"
	end
end
