return function()
	local WeldLib = require(script.Parent)

	describe("WeldLib", function()
		it("should create a new Weld instance", function()
			local part0 = Instance.new("Part")
			local part1 = Instance.new("Part")
			local weld = WeldLib.NewWeld(part0, part1)

			expect(weld).to.be.ok()
			expect(weld.ClassName).to.equal("Weld")
			expect(weld.Part0).to.equal(part0)
			expect(weld.Part1).to.equal(part1)
		end)

		it("should break a Weld instance", function()
			local part0 = Instance.new("Part")
			local part1 = Instance.new("Part")
			local weld = WeldLib.NewWeld(part0, part1)
			weld.Parent = part0

			WeldLib.BreakWeld(weld)

			expect(weld.Parent).never.to.equal(part0)
		end)

		it("should update a Weld instance", function()
			local part0 = Instance.new("Part")
			local part1 = Instance.new("Part")
			local weld = WeldLib.NewWeld(part0, part1)

			local new_part0 = Instance.new("Part")
			local new_part1 = Instance.new("Part")
			local new_c0 = CFrame.new(1, 2, 3)
			local new_c1 = CFrame.new(4, 5, 6)

			WeldLib.UpdateWeld(weld, new_part0, new_part1, new_c0, new_c1)

			expect(weld.Part0).to.equal(new_part0)
			expect(weld.Part1).to.equal(new_part1)
			expect(weld.C0).to.equal(new_c0)
			expect(weld.C1).to.equal(new_c1)
		end)

		it("should weld a Model to its PrimaryPart", function()
			local model = Instance.new("Model")
			local primary_part = Instance.new("Part")
			model.PrimaryPart = primary_part

			local part1 = Instance.new("Part")
			local part2 = Instance.new("Part")
			local part3 = Instance.new("Part")

			part1.Parent = model
			part2.Parent = model
			part3.Parent = model

			WeldLib.WeldModelToPrimaryPart(model)

			expect(primary_part.Anchored).to.equal(true)
			expect(part1.Anchored).to.equal(false)
			expect(part2.Anchored).to.equal(false)
			expect(part3.Anchored).to.equal(false)
		end)

		it("should unweld a Model", function()
			local model = Instance.new("Model")
			local part1 = Instance.new("Part")
			local part2 = Instance.new("Part")
			local part3 = Instance.new("Part")

			model.PrimaryPart = part1

			part1.Parent = model
			part2.Parent = model
			part3.Parent = model

			WeldLib.WeldModelToPrimaryPart(model)
			WeldLib.UnweldModel(model)

			expect(part1.Parent).never.to.equal(model.PrimaryPart)
			expect(part2.Parent).never.to.equal(model.PrimaryPart)
			expect(part3.Parent).never.to.equal(model.PrimaryPart)
		end)

		it("should error if Model has no PrimaryPart", function()
			local model = Instance.new("Model")

			expect(function()
				WeldLib.WeldModelToPrimaryPart(model)
			end).to.throw()
		end)

		it("should error if Model is nil", function()
			expect(function()
				WeldLib.WeldModelToPrimaryPart(nil)
			end).to.throw()
		end)

		it("should error if Part0 is nil", function()
			local part1 = Instance.new("Part")

			expect(function()
				WeldLib.NewWeld(nil, part1)
			end).to.throw()
		end)

		it("should error if Part1 is nil", function()
			local part0 = Instance.new("Part")

			expect(function()
				WeldLib.NewWeld(part0, nil)
			end).to.throw()
		end)

		it("should error if Part0 is not a BasePart", function()
			local part0 = Instance.new("Model")
			local part1 = Instance.new("Part")

			expect(function()
				WeldLib.NewWeld(part0, part1)
			end).to.throw()
		end)

		it("should error if Part1 is not a BasePart", function()
			local part0 = Instance.new("Part")
			local part1 = Instance.new("Model")

			expect(function()
				WeldLib.NewWeld(part0, part1)
			end).to.throw()
		end)

		it("should error if Weld is nil", function()
			expect(function()
				WeldLib.BreakWeld(nil)
			end).to.throw()
		end)

		it("should error if Weld is not a Weld", function()
			local weld = Instance.new("Model")

			expect(function()
				WeldLib.BreakWeld(weld)
			end).to.throw()
		end)
	end)
end
