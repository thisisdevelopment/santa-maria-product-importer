RSpec.describe 'santa maria v2' do
  class SpyPresenter
    attr_reader :products, :variants

    def initialize
      @products = []
      @variants = []
    end

    def product(product)
      @products << product
    end

    def variant(variant)
      @variants << variant
    end
  end

  context do
    before do
      stub_request(:get, "https://api/api/v2/products")
        .to_return(
          body: response.to_json,
          status: 200
        )
    end

    context 'given two products with a variant' do
      before do
        stub_request(:get, "https://api/api/v2/products/192871-19291-39192-109283")
          .to_return(
            body: { sku: [{ articleNumber: '1111111' }] }.to_json,
            status: 200
          )

        stub_request(:get, "https://api/api/v2/products/192871-19291-39192-982910")
          .to_return(
            body: { sku: [{ articleNumber: '2222222' }, { articleNumber: '3333333' }] }.to_json,
            status: 200
          )
      end

      let(:response) do
        response = {
          products: [{
                       globalId: '192871-19291-39192-109283',
                       productType: 'Paint',
                       name: 'Easycare',
                       uri: 'easy-care'
                     },
                     {
                       globalId: '192871-19291-39192-982910',
                       productType: 'Paint',
                       name: 'Paint Mixing Easycare',
                       uri: 'paint-mixing-easy-care'
                     }]
        }
      end

      it 'is able to extract those products' do
        use_case = SantaMaria::UseCase::FetchProducts.new(
          santa_maria: SantaMaria::Gateway::SantaMariaV2.new('http://api/')
        )

        spy_presenter = SpyPresenter.new
        use_case.execute(spy_presenter)

        expect(spy_presenter.products[0][:id]).to eq('192871-19291-39192-109283')
        expect(spy_presenter.products[0][:type]).to eq('Paint')
        expect(spy_presenter.products[0][:name]).to eq('Easycare')
        expect(spy_presenter.products[0][:uri_name]).to eq('easy-care')

        expect(spy_presenter.products[1][:id]).to eq('192871-19291-39192-982910')
        expect(spy_presenter.products[1][:type]).to eq('Paint')
        expect(spy_presenter.products[1][:name]).to eq('Paint Mixing Easycare')
        expect(spy_presenter.products[1][:uri_name]).to eq('paint-mixing-easy-care')

        expect(spy_presenter.variants[0][:id]).to eq('192871-19291-39192-109283')
        expect(spy_presenter.variants[0][:article_number]).to eq('1111111')

        expect(spy_presenter.variants[1][:id]).to eq('192871-19291-39192-982910')
        expect(spy_presenter.variants[1][:article_number]).to eq('2222222')

        expect(spy_presenter.variants[2][:id]).to eq('192871-19291-39192-982910')
        expect(spy_presenter.variants[2][:article_number]).to eq('3333333')
      end
    end
  end
end
