
"""
"""
function draworbitsdiagram(f::Function, x0::Real=Inf; preiterations::Int=500, iterations::Int=500)
  # Veryfying functions
  @assert typeof(f(.1,.1)) <: Real

  SDDGraphics.newdrawing()

  #SDDGraphics.updatecolorarray(iterations)

  if isinf(x0)
    x0 = (SDDGraphics.ymax() - SDDGraphics.ymin())/2
  end

  λmin = SDDGraphics.xmin()
  λmax = SDDGraphics.xmax()

  if SDDGraphics.backend() == :luxor ## || other vectorial
    Δλ = (λmax - λmin)/SDDGraphics.width()

    for λ in λmin:Δλ:λmax
      xn = x0
      for n in 1:preiterations
          xn = f(λ,xn)
      end # for n preiterations
      #SDDGraphics.color(escapetime)
      for n in 1:iterations
        xn = f(λ,xn)
        if SDDGraphics.insiderectregion(λ,xn)
          SDDGraphics.drawpoint(λ,xn)
        end
      end # for n iterations
    end # for λ

  elseif SDDGraphics.backend() == :images

    for w in 1:SDDGraphics.width()
      λ = λmin + w*(λmax - λmin)/SDDGraphics.width()
      xn = x0
      for n in 1:preiterations
          xn = f(λ,xn)
      end # for n preiterations
      #SDDGraphics.color(escapetime)
      for n in 1:iterations
        xn = f(λ,xn)
        if xn > SDDGraphics.ymin() && xn < SDDGraphics.ymax()
          h = Integer(ceil(SDDGraphics.height() + SDDGraphics.height()*(SDDGraphics.ymin()-xn)/(SDDGraphics.ymax()-SDDGraphics.ymin())))
          #if h > 0 && h <= SDDGraphics.height()
          SDDGraphics.drawpixel(w,h)
        end
      end # for n iterations
    end # for w

  end # if :luxor elseif :images

  SDDGraphics.drawing()
end


"""
"""
#function drawbifurcationsdiagram
