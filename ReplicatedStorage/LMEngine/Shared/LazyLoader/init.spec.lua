return function()
	local TestModule = game:GetService("ReplicatedStorage").LMEngine.Test.Modules.Test
	local LazyLoader = require(script.Parent)

	describe("LazyLoader", function()
		it("should create a new LazyLoader", function()
			local lazy_loader = LazyLoader.new()

			expect(lazy_loader).to.be.ok()
			expect(lazy_loader._modules).to.be.a("table")
		end)

		it("should add a module to the LazyLoader", function()
			local lazy_loader = LazyLoader.new()
			local module = Instance.new("ModuleScript")
			module.Name = "TestModule"

			lazy_loader:AddModule(module)

			expect(lazy_loader._modules["TestModule"]).to.equal(module)
		end)

		it("should not add the LazyLoader module to the LazyLoader", function()
			local lazy_loader = LazyLoader.new()
			local module = script

			lazy_loader:AddModule(module)

			expect(lazy_loader._modules["LazyLoader"]).never.to.be.ok()
		end)

		it("should get a module from the LazyLoader", function()
			local lazy_loader = LazyLoader.new()

			lazy_loader:AddModule(TestModule)

			expect(lazy_loader:GetModule("Test")).to.be.a("table")
		end)

		it("should load a module from the LazyLoader", function()
			local lazy_loader = LazyLoader.new()
			local module = Instance.new("ModuleScript")
			module.Name = "TestModule"
			module.Source = "return {}"

			lazy_loader:AddModule(module)

			expect(lazy_loader:GetModule("TestModule")).to.be.a("table")
		end)
	end)
end
