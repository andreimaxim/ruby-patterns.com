require_relative "asset"

module Jekyll
  module DriveShaft
    class Assembly
      class << self
        def assets
          @@assets ||= {}
        end

        def add(url:, source_path:, destination_path:)
          assets[url] = Jekyll::DriveShaft::Asset.new(
            url: url,
            source_path: source_path,
            destination_path: destination_path
          )
        end

        def [](url)
          assets[url]
        end

        def create_fingerprinted_assets!
          # [TODO]: Replace the asset paths within the assets to use the fingerprinted versions
          assets.values.each { |asset| asset.create_fingerprinted_copy! }
        end
      end
    end
  end
end

Jekyll::Hooks.register(:site, :pre_render) do |site|
  site.static_files_to_write.each do |file|
    url = file.url
    source_path = file.path
    destination_path = file.destination(site.dest)

    Jekyll::DriveShaft::Assembly.add(url: url, source_path: source_path, destination_path: destination_path)
  end
end

Jekyll::Hooks.register([:documents, :pages], :post_render) do |document|
  Jekyll::DriveShaft::Assembly.assets.each do |url, asset|
    document.output.gsub!(url, asset.digested_url)
  end
end

Jekyll::Hooks.register(:site, :post_write) do
  Jekyll::DriveShaft::Assembly.create_fingerprinted_assets!
end
